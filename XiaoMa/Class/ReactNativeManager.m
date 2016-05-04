//
//  ReactNativeManager.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/4/28.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ReactNativeManager.h"
#import "DownloadFileOp.h"

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
    NSURL *defUrl = CKURLForMainBundle(@"RCTBundle");
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
    return [op rac_getRequest];
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

- (BOOL)linkFromUrl:(NSURL *)url1 toUrl:(NSURL *)url2
{
    NSError *error;
    BOOL rst = [[NSFileManager defaultManager] createSymbolicLinkAtURL:url2 withDestinationURL:url1 error:&error];
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
