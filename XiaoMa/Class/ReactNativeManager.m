//
//  ReactNativeManager.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/4/28.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ReactNativeManager.h"

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
    //如果不存在最近的版本，将资源里的rct版本链接到最近版本
    NSURL *latestUrl = [self latestBundleUrl];
    if (![self bundleExistsAtUrl:[self latestBundleUrl]]) {
        NSURL *url = CKURLForMainBundle(@"ReactNativeBundle");
        [self linkFromUrl:CKURLForMainBundle(@"ReactNativeBundle") toUrl:latestUrl];
    }
    if (latestUrl) {
        _defaultConfig = [HKRCTPackageConfig configWithUrl:latestUrl];
    }
}

- (RACSignal *)rac_checkPackageVersionUpdate
{
    return nil;
}

- (RACSignal *)rac_downloadPackageForUrl:(NSURL *)url
{
    return nil;
}

#pragma mark - Util
- (BOOL)bundleExistsAtUrl:(NSURL *)url
{
    BOOL isDir;
    BOOL rst = [[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:&isDir];
    return rst && isDir;
}

- (NSURL *)latestBundleUrl
{
    return CKURLForDocument(@"rct/bundle/latest");
}

- (NSURL *)localUrlForConfig:(HKRCTPackageConfig *)config
{
    return CKURLForDocument([NSString stringWithFormat:@"rct/bundle/%@", config.bundleVersion]);
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
