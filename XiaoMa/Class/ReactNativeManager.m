//
//  ReactNativeManager.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/4/28.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ReactNativeManager.h"
#import "DownloadFileOp.h"
#import <ZipArchive/ZipArchive.h>
#import <Google-Diff-Match-Patch/DiffMatchPatch.h>
#import "HKSecurityManager.h"
#import "NSData+MD5Digest.h"

//更新间隔暂定为6小时
#define kUpdateTimeInterval         6 * 60 * 60

@interface ReactNativeManager ()
@property (nonatomic, assign) NSTimeInterval latestUpdateTime;
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

- (void)loadDefaultBundle
{
    NSURL *defUrl = CKURLForMainBundle(@"rctpkg");
    NSURL *latestUrl = CKURLForDocument(@"rct/bundle/latest");
    HKRCTPackageConfig *defConf = [HKRCTPackageConfig configWithUrl:[defUrl URLByAppendingPathComponent:@"config.json"]];
    HKRCTPackageConfig *latestConf = [HKRCTPackageConfig configWithUrl:[latestUrl URLByAppendingPathComponent:@"config.json"]];

    if ([defConf.bundleVersion compare:latestConf.bundleVersion options:NSCaseInsensitiveSearch] > 0) {
        [self removeAtUrl:latestUrl];
        [self makeDirWithUrl:[latestUrl URLByDeletingLastPathComponent]];
        [self linkFromUrl:defUrl toUrl:latestUrl];
        latestConf = defConf;
    }
    
    _defaultPackageConfig = defConf;
    _latestPackageConfig = latestConf;
}

#pragma mark - Network
- (RACSignal *)rac_checkAndUpdatePackageIfNeeded
{
    //去检测更新
    if ([[NSDate date] timeIntervalSince1970] - self.latestUpdateTime > kUpdateTimeInterval) {
        return [self rac_checkAndUpdatePackage];
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
        GetReactNativePackageOp *op1 = tuple.first;
        DownloadFileOp *op2 = tuple.second;
        return [self verifyPackageAtPath:op2.req_savePath withSignature:op1.rsp_patchsign];
    }] filter:^BOOL(RACTuple *tuple) {
        
        //解压并合并增量包
        @strongify(self);
        GetReactNativePackageOp *op = [tuple first];
        return [self unzipFileWithPackageOp:op] && [self applyPatchWithPackageOp:op];
    }] doNext:^(id x) {
        
        //刷新版本配置信息
        @strongify(self);
        self->_latestPackageConfig = [HKRCTPackageConfig configWithUrl:CKURLForDocument(@"rct/bundle/latest/config.json")];
    }] deliverOn:[RACScheduler mainThreadScheduler]];
    return signal;
}

- (RACSignal *)rac_checkPackageVersion
{
    GetReactNativePackageOp *op = [GetReactNativePackageOp operation];
    op.req_version = self.latestPackageConfig.bundleVersion;
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
    NSURL *dirUrl = CKURLForDocument([NSString stringWithFormat:@"rct/bundle/%@.temp/", pkgop.rsp_version]);
    if ([self existsAtUrl:dirUrl]) {
        [self removeAtUrl:dirUrl];
    }
    [self makeDirWithUrl:[dirUrl URLByAppendingPathComponent:@"patch/"]];
    NSString *patchName = [NSString stringWithFormat:@"patch/%@", [pkgop.rsp_patchurl lastPathComponent]];
    DownloadFileOp *op = [DownloadFileOp operation];
    op.req_url = pkgop.rsp_patchurl;
    op.req_savePath = [[dirUrl URLByAppendingPathComponent:patchName] path];
    return [[op rac_getRequest] map:^id(DownloadFileOp *op) {
        return RACTuplePack(pkgop, op);
    }];
}

#pragma mark - Patch
- (BOOL)verifyPackageAtPath:(NSString *)path withSignature:(NSString *)sign
{
    NSData *patchData = [NSData dataWithContentsOfFile:path];
    NSString *strmd5 = [patchData MD5HexDigest];
    return [[HKSecurityManager sharedManager] verifyWithRSASignature:sign forMessage:strmd5];
}

- (BOOL)unzipFileWithPackageOp:(GetReactNativePackageOp *)op
{
    NSString *path = CKPathForDocument([NSString stringWithFormat:@"rct/bundle/%@.temp/patch/%@",
                                        op.rsp_version, [op.rsp_patchurl lastPathComponent]]);
    return [self unzipFileAtPath:path];
}

- (BOOL)unzipFileAtPath:(NSString *)path
{
    ZipArchive *zip = [[ZipArchive alloc] init];
    if (![zip UnzipOpenFile:path]) {
        return NO;
    }
    NSString *base = [path stringByDeletingLastPathComponent];
    NSString *name = [[path lastPathComponent] stringByDeletingPathExtension];
    return [zip UnzipFileTo:[base stringByAppendingPathComponent:name] overWrite:YES];
}

- (BOOL)applyPatchWithPackageOp:(GetReactNativePackageOp *)op
{
    //合并jsbundle
    if (![self applyPatchForJsbundleWithPackage:op]) {
        return NO;
    }
    //合并asserts
    NSURL *oldAssets = CKURLForDocument(@"rct/bundle/latest/assets");
    NSURL *newAssets = CKURLForDocument([NSString stringWithFormat:@"rct/bundle/%@.temp/assets", op.rsp_version]);
    NSURL *patchAssets = CKURLForDocument([NSString stringWithFormat:@"rct/bundle/%@.temp/patch/%@/assets",
                                           op.rsp_version, [[op.rsp_patchurl lastPathComponent] stringByDeletingPathExtension]]);
    [self linkDirectoryFromUrl:oldAssets toUrl:newAssets shouldCopy:NO];
    [self linkDirectoryFromUrl:patchAssets toUrl:newAssets shouldCopy:YES];
    
    //替换config
    NSURL *tempConfig = CKURLForDocument([NSString stringWithFormat:@"rct/bundle/%@.temp/patch/%@/config.json",
                                          op.rsp_version, [[op.rsp_patchurl lastPathComponent] stringByDeletingPathExtension]]);
    NSURL *destConfig = CKURLForDocument([NSString stringWithFormat:@"rct/bundle/%@.temp/config.json", op.rsp_version]);
    [self moveFromUrl:tempConfig toUrl:destConfig];
    
    //将临时目录替换为正式的版本目录
    NSURL *latestUrl = CKURLForDocument(@"rct/bundle/latest");
    NSURL *destUrl = CKURLForDocument([NSString stringWithFormat:@"rct/bundle/%@", op.rsp_version]);
    NSURL *tempUrl = CKURLForDocument([NSString stringWithFormat:@"rct/bundle/%@.temp", op.rsp_version]);
    [self removeAtUrl:destUrl];
    [self moveFromUrl:tempUrl toUrl:destUrl];
    [self removeAtUrl:latestUrl];
    [self linkFromUrl:destUrl toUrl:latestUrl];
    
    return YES;
}

- (BOOL)applyPatchForJsbundleWithPackage:(GetReactNativePackageOp *)op
{
    NSURL *jsPatchesUrl = CKURLForDocument([NSString stringWithFormat:@"rct/bundle/%@.temp/patch/%@/jsbundle.txt",
                                            op.rsp_version, [[op.rsp_patchurl lastPathComponent] stringByDeletingPathExtension]]);
    NSURL *jsBundleUrl = CKURLForDocument(@"rct/bundle/latest/main.jsbundle");

    DiffMatchPatch *dmp = [[DiffMatchPatch alloc] init];
    
    NSString *patchText = [[NSString alloc] initWithContentsOfURL:jsPatchesUrl encoding:NSUTF8StringEncoding error:nil];
    if (!patchText) {
        return NO;
    }
    NSArray *patches = [dmp patch_fromText:patchText error:nil];
    
    NSString *oldJsText = [[NSString alloc] initWithContentsOfURL:jsBundleUrl encoding:NSUTF8StringEncoding error:nil];
    if (!oldJsText) {
        return NO;
    }
    NSArray *results = [dmp patch_apply:patches toString:oldJsText];
    NSString *newJsText = [results safetyObjectAtIndex:0];
    
    NSURL *newJsBundleUrl = CKURLForDocument([NSString stringWithFormat:@"rct/bundle/%@.temp/main.jsbundle", op.rsp_version]);
    if (![newJsText writeToURL:newJsBundleUrl atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
        return NO;
    }
    return YES;
}

- (void)linkDirectoryFromUrl:(NSURL *)fromUrl toUrl:(NSURL *)toUrl shouldCopy:(BOOL)shouldCopy
{
    [self makeDirWithUrl:toUrl];
    NSFileManager *mgr = [NSFileManager defaultManager];
    for (NSString *path in [mgr subpathsAtPath:[fromUrl path]]) {
        BOOL isDir = NO;
        NSString *absPath1 = [[fromUrl path] stringByAppendingPathComponent:path];
        NSString *absPath2 = [[toUrl path] stringByAppendingPathComponent:path];
        //文件
        if ([mgr fileExistsAtPath:absPath1 isDirectory:&isDir] && !isDir) {
            if (shouldCopy) {
                [mgr copyItemAtPath:absPath1 toPath:absPath2 error:nil];
            }
            else {
                [mgr createSymbolicLinkAtPath:absPath2 withDestinationPath:absPath1 error:nil];
            }
        }
        //目录
        else {
            [mgr createDirectoryAtPath:absPath2 withIntermediateDirectories:nil attributes:nil error:nil];
        }
    }
}

#pragma mark - Url
- (NSURL *)latestJSBundleUrl
{
    return CKURLForDocument(@"rct/bundle/latest/main.jsbundle");
}
#pragma mark - Util
- (BOOL)existsAtUrl:(NSURL *)url
{
    BOOL isDir;
    BOOL rst = [[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:&isDir];
    return rst && isDir;
}

- (BOOL)removeAtUrl:(NSURL *)url
{
    NSError *error;
    BOOL rst = [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    if (!rst) {
        DebugErrorLog(@"%@", error);
    }
    return rst;
}

- (BOOL)moveFromUrl:(NSURL *)url1 toUrl:(NSURL *)url2
{
    NSError *error;
    BOOL rst = [[NSFileManager defaultManager] moveItemAtURL:url1 toURL:url2 error:&error];
    if (!rst) {
        DebugErrorLog(@"%@", error);
    }
    return rst;
}

- (BOOL)linkFromUrl:(NSURL *)url1 toUrl:(NSURL *)url2
{
    NSError *error;
    BOOL rst = [[NSFileManager defaultManager] linkItemAtURL:url1 toURL:url2 error:&error];
    if (!rst) {
        DebugErrorLog(@"%@", error);
    }
    return rst;
}

- (BOOL)makeDirWithUrl:(NSURL *)url
{
    NSError *error;
    BOOL rst = [[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES
                                                         attributes:nil error:&error];
    if (!rst) {
        DebugErrorLog(@"%@", error);
    }
    return rst;
}

@end
