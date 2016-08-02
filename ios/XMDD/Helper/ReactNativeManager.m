//
//  ReactNativeManager.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/4/28.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ReactNativeManager.h"
#import "AFDownloadRequestOperation.h"
#import <ZipArchive/ZipArchive.h>
#import <Google-Diff-Match-Patch/DiffMatchPatch.h>
#import "HKSecurityManager.h"
#import "HKFileCache.h"
#import "NSData+MD5Digest.h"
#import "NSString+UUID.h"

//更新间隔暂定为6小时
#define kUpdateTimeInterval        6 * 60 * 60

@interface ReactNativeManager ()
@property (nonatomic, assign) NSTimeInterval latestUpdateTime;
@property (nonatomic, strong) HKFileCache *fileCache;
@property (nonatomic, assign) BOOL isReactNativeEnabledForNotLogin;
@end

@implementation ReactNativeManager

+ (instancetype)sharedManager
{
    static ReactNativeManager *g_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_manager = [[ReactNativeManager alloc] init];
    });
    return g_manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.fileCache = [[HKFileCache alloc] initWithCachePath:CKPathForCache(@"rct")];
        //500MB
        self.fileCache.maxCacheSize = 1024 * 1024 * 500;
        //100MB
        self.fileCache.retentionCacheSize = 1024 * 1024 * 100;
    }
    return self;
}

#pragma mark - Bundle
- (void)loadDefaultBundle
{
    @weakify(self);
    _loadingSignal = [RACSignal startEagerlyWithScheduler:[RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh] block:^(id<RACSubscriber> subscriber) {
        
        @strongify(self);
        //先清理缓存目录
        [self.fileCache cleanDisk];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSString *bundleName = [self fetchDefaultBundleName];
        NSString *defdir = CKPathForDocument(@"rct/bundle/default");
        NSString *defPath = [defdir stringByAppendingPathComponent:bundleName];
        NSString *latest = CKPathForDocument(@"rct/bundle/latest");
        //提取默认包
        if (![fileMgr fileExistsAtPath:defPath]) {
            [self extractDefaultBundle:bundleName];
        }
        //初始化配置信息
        HKRCTPackageConfig *defConfig = [HKRCTPackageConfig configWithPath:
                                         [defPath stringByAppendingPathComponent:@"contents/rctbundle.json"]];
        HKRCTPackageConfig *latestConfig = [HKRCTPackageConfig configWithPath:
                                            [latest stringByAppendingPathComponent:@"contents/rctbundle.json"]];
        //当前默认版本大于上次检测到的版本
        if ([defConfig.bundleVersion compare:latestConfig.bundleVersion options:NSNumericSearch] == NSOrderedDescending) {
            [self removeAtPath:latest];
            [self linkFromPath:defPath toPath:latest];
            latestConfig = defConfig;
        }
        _defaultPackageConfig = defConfig;
        _latestPackageConfig = latestConfig;
        [subscriber sendCompleted];
    }];
}

- (NSString *)fetchDefaultBundleName {
    NSString *dir = CKPathForMainBundle(@"RCTBundle");
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil];
    NSString *bundlezip = [files firstObjectByFilteringOperator:^BOOL(NSString *filename) {
        return [[filename pathExtension] isEqualToString:@"zip"];
    }];
    return [bundlezip stringByDeletingPathExtension];
}

- (void)extractDefaultBundle:(NSString *)bundleName {
    NSString *defdir = CKPathForDocument(@"rct/bundle/default");
    NSString *defPath = [defdir stringByAppendingPathComponent:bundleName];
    NSString *srcpath = CKPathForMainBundle([NSString stringWithFormat:@"RCTBundle/%@.zip", bundleName]);
    NSString *tempdir = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString uuidString]];
    NSString *contents = [tempdir stringByAppendingPathComponent:@"contents.zip"];
    NSString *signfile = [tempdir stringByAppendingPathComponent:@"sign.json"];
    //整体解压安装包
    if (![self unzipFrom:srcpath to:tempdir]) {
        return;
    }
    //验证包签名
    if (![self verifyContentsAtPath:contents withSignatureFile:signfile]) {
        return;
    }
    //解压内容
    if (![self unzipFrom:contents to:[contents stringByDeletingPathExtension]]) {
        return;
    }
    //移除老的默认版本
    [self removeAtPath:defdir];
    //链接新版本
    [self makeDirWithPath:defdir];
    [self linkFromPath:tempdir toPath:defPath];
}

#pragma mark - Zip
- (BOOL)unzipFrom:(NSString *)srcfile to:(NSString *)destfile
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:destfile]) {
        [[NSFileManager defaultManager] removeItemAtPath:destfile error:nil];
    }
    ZipArchive *zip = [[ZipArchive alloc] init];
    if (![zip UnzipOpenFile:srcfile]) {
        return NO;
    }
    return [zip UnzipFileTo:destfile overWrite:YES];
    return YES;
}


- (BOOL)unzipFileAtPath:(NSString *)path
{
    return [self unzipFrom:path to:[path stringByDeletingPathExtension]];
}


#pragma mark - Network
- (RACSignal *)rac_checkAndUpdatePackageIfNeeded
{
    //去检测更新
    if ([[NSDate date] timeIntervalSince1970] - self.latestUpdateTime > kUpdateTimeInterval) {
        return [self.loadingSignal concat:[self rac_checkAndUpdatePackage]];
    }
    return [RACSignal empty];
}


- (RACSignal *)rac_checkAndUpdatePackage
{
    @weakify(self);
    RACSignal *signal = [[[[[[self rac_checkPackageVersion] flattenMap:^RACStream *(GetReactNativePackageOp *op) {

        @strongify(self);
        return [self rac_downloadPackageWithPackageOp:op];
    }] filter:^BOOL(RACTuple *tuple) {

        //验证增量签名，防止包被篡改
        @strongify(self);
        GetReactNativePackageOp *pkgop = tuple.second;
        NSString *contents = [[tuple.first stringByDeletingPathExtension] stringByAppendingPathComponent:@"contents.zip"];
        return [self unzipFileAtPath:tuple.first] && [self verifyContentsAtPath:contents withSignature:pkgop.rsp_patchsign];
    }] filter:^BOOL(RACTuple *tuple) {
        
        //patch增量包
        @strongify(self);
        return [self applyPatchAtPath:tuple.first withPackageOp:tuple.second];
    }] doNext:^(id x) {
        
        //刷新版本配置信息
        @strongify(self);
        self.latestUpdateTime = [[NSDate date] timeIntervalSince1970];
        self->_latestPackageConfig = [HKRCTPackageConfig configWithPath:CKPathForDocument(@"rct/bundle/latest/contents/rctbundle.json")];
    }] deliverOn:[RACScheduler mainThreadScheduler]];
    return signal;
}


- (RACSignal *)rac_checkPackageVersion
{
    GetReactNativePackageOp *op = [GetReactNativePackageOp operation];
    op.req_projectname = self.latestPackageConfig.projectName;
    op.req_rctversion = self.latestPackageConfig.bundleVersion;
    op.req_timetag = self.latestPackageConfig.timetag;
    op.req_buildtype = self.latestPackageConfig.buildType;
    op.req_appversion = gAppMgr.deviceInfo.appVersion;
    
    return [[op rac_postRequest] catch:^RACSignal *(NSError *error) {
        
        if (error.code == 304) {
            return [RACSignal empty];
        }
        return [RACSignal error:error];
    }];
}


- (RACSignal *)rac_downloadPackageWithPackageOp:(GetReactNativePackageOp *)pkgop
{
    if (pkgop.rsp_patchurl.length == 0) {
        return [RACSignal error:[NSError errorWithDomain:@"url为空" code:-1 userInfo:nil]];
    }
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:pkgop.rsp_patchurl]];
        NSString *path = [self.fileCache pathForName:[pkgop.rsp_patchurl lastPathComponent]];
        AFDownloadRequestOperation *op = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:path shouldResume:YES];
        op.shouldOverwrite = YES;
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [subscriber sendNext:RACTuplePack(path, pkgop)];
            [subscriber sendCompleted];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            DebugErrorLog(@"%@ download:%@\n%@", kErrPrefix, pkgop.rsp_patchurl, error);
            [subscriber sendError:error];
        }];
        [gNetworkMgr.reactManager.operationQueue addOperation:op];
        return nil;
    }];
}

#pragma mark - Verify
- (BOOL)verifyContentsAtPath:(NSString *)path withSignature:(NSString *)sign
{
    NSData *patchData = [NSData dataWithContentsOfFile:path];
    NSString *strmd5 = [patchData MD5HexDigest];
    return [[HKSecurityManager sharedManager] verifyWithRSASignature:sign forMessage:strmd5];
}

- (BOOL)verifyContentsAtPath:(NSString *)path withSignatureFile:(NSString *)signfile {
    NSString *pkgname = [path lastPathComponent];
    NSData *signData = [NSData dataWithContentsOfFile:signfile];
    if (!signData) {
        return NO;
    }
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:signData options:0 error:nil];
    if (jsonDict && pkgname) {
        NSString *sign = jsonDict[pkgname];
        return [self verifyContentsAtPath:path withSignature:sign];
    }
    return NO;
}

- (BOOL)verifyJSBundleAtPath:(NSString *)path withChecksums:(NSString *)checksums {
    if (checksums.length == 0) {
        return YES;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return NO;
    }
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [[data MD5HexDigest] isEqualToString:checksums];
}

#pragma mark - Patch
- (BOOL)applyPatchAtPath:(NSString *)patchPath withPackageOp:(GetReactNativePackageOp *)op
{
    NSString *orgDir = [patchPath stringByDeletingPathExtension];
    NSString *contents = [orgDir stringByAppendingPathComponent:@"contents"];
    NSString *tempDir = [self.fileCache pathForName:[NSString uuidString]];
    //解压contents
    if (![self unzipFileAtPath:[orgDir stringByAppendingPathComponent:@"contents.zip"]]) {
        return NO;
    }
    NSString *destContents = [tempDir stringByAppendingPathComponent:@"contents"];
    //复制patch的contents目录
    [self linkDirectoryFromPath:contents toPath:destContents shouldCopy:NO];
    //合并jsbundle
    if (![self applyPatchForJsbundleFromContents:contents toContents:destContents withChecksums:op.rsp_jssummary]) {
        return NO;
    }
    //合并assets
    [self applyPatchForAssetsFromContents:contents toContents:destContents];
    //复制sign文件
    [self linkFromPath:[orgDir stringByAppendingPathComponent:@"sign.json"]
                toPath:[tempDir stringByAppendingPathComponent:@"sign.json"]];
    //复制到documents文件夹
    NSString *latestPath = CKPathForDocument(@"rct/bundle/latest");
    [self removeAtPath:latestPath];
    [self linkDirectoryFromPath:tempDir toPath:latestPath shouldCopy:NO];

    return YES;
}

///合并asserts
- (void)applyPatchForAssetsFromContents:(NSString *)orgContents toContents:(NSString *)destContents {
    NSString *oldAssets = CKPathForDocument(@"rct/bundle/latest/assets");
    NSString *newAssets = [destContents stringByAppendingPathComponent:@"assets"];
    NSString *patchAssets = [orgContents stringByAppendingPathComponent:@"assets"];
    [self linkDirectoryFromPath:oldAssets toPath:newAssets shouldCopy:NO];
    [self linkDirectoryFromPath:patchAssets toPath:newAssets shouldCopy:NO];
}


- (BOOL)applyPatchForJsbundleFromContents:(NSString *)org toContents:(NSString *)dest withChecksums:(NSString *)checksums
{
    NSString *jsbundlePath = [org stringByAppendingPathComponent:@"main.jsbundle"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:jsbundlePath]) {
        return [self verifyJSBundleAtPath:jsbundlePath withChecksums:checksums];
    }
    
    DiffMatchPatch *dmp = [[DiffMatchPatch alloc] init];

    NSString *patchText = [[NSString alloc] initWithContentsOfFile:[org stringByAppendingPathComponent:@"main.jsbundle.diff"]
                                                          encoding:NSUTF8StringEncoding error:nil];
    if (!patchText) {
        return NO;
    }
    NSArray *patches = [dmp patch_fromText:patchText error:nil];

    NSString *oldJsText = [[NSString alloc] initWithContentsOfFile:CKPathForDocument(@"rct/bundle/latest/contents/main.jsbundle")
                                                          encoding:NSUTF8StringEncoding error:nil];
    if (!oldJsText) {
        return NO;
    }
    NSArray *results = [dmp patch_apply:patches toString:oldJsText];
    NSString *newJsText = [results safetyObjectAtIndex:0];
    
    return [newJsText writeToFile:[dest stringByAppendingPathComponent:@"main.jsbundle"]
                       atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)linkDirectoryFromPath:(NSString *)fromPath toPath:(NSString *)toPath shouldCopy:(BOOL)shouldCopy
{
    [self makeDirWithPath:toPath];
    NSFileManager *mgr = [NSFileManager defaultManager];
    for (NSString *path in [mgr subpathsAtPath:fromPath]) {
        BOOL isDir = NO;
        NSString *absPath1 = [fromPath stringByAppendingPathComponent:path];
        NSString *absPath2 = [toPath stringByAppendingPathComponent:path];
        //文件
        if ([mgr fileExistsAtPath:absPath1 isDirectory:&isDir] && !isDir) {
            if (shouldCopy) {
                [mgr copyItemAtPath:absPath1 toPath:absPath2 error:nil];
            }
            else {
                [mgr linkItemAtPath:absPath1 toPath:absPath2 error:nil];
            }
        }
        //目录
        else {
            [mgr createDirectoryAtPath:absPath2 withIntermediateDirectories:NO attributes:nil error:nil];
        }
    }
}

#pragma mark - Switch
- (BOOL)isReactNativeEnabled {
    if (self.isReactNativeEnabledForNotLogin) {
        return YES;
    }
    //TODO: 从UserDefault中获取当前user相关的参数
    return NO;
}

#pragma mark - Util
- (NSURL *)latestJSBundleUrl {
    return CKURLForDocument(@"rct/bundle/latest/contents/main.jsbundle");
}


- (BOOL)removeAtPath:(NSString *)path {
    NSError *error;
    BOOL rst = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    if (!rst) {
        DebugErrorLog(@"%@", error);
    }
    return rst;
}


- (BOOL)linkFromPath:(NSString *)path1 toPath:(NSString *)path2 {
    NSError *error;
    BOOL rst = [[NSFileManager defaultManager] linkItemAtPath:path1 toPath:path2 error:&error];
    if (!rst) {
        DebugErrorLog(@"%@", error);
    }
    return rst;
}


- (BOOL)makeDirWithPath:(NSString *)path {
    NSError *error;
    BOOL rst = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                                          attributes:nil error:&error];
    if (!rst) {
        DebugErrorLog(@"%@", error);
    }
    return rst;
   
}

@end
