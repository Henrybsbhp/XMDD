//
//  HKFileCache.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/25.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKFileCache.h"

@implementation HKFileCache

- (instancetype)initWithCachePath:(NSString *)cachePath {
    self = [super init];
    if (self) {
        self->_cachePath = cachePath;
        NSError *error;
        BOOL rst = [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES
                                                              attributes:nil error:&error];
        if (!rst && error) {
            DebugErrorLog(@"%@", error);
        }
    }
    return self;
}

- (void)cleanDisk {
    NSURL *diskCacheURL = [NSURL fileURLWithPath:self.cachePath isDirectory:YES];
    NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
    NSDictionary *values = [diskCacheURL resourceValuesForKeys:resourceKeys error:nil];
    NSUInteger totalSize = [values[NSURLTotalFileAllocatedSizeKey] unsignedIntegerValue];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (totalSize < self.maxCacheSize) {
        return;
    }
    //获取目录下有所文件
    NSArray *contents = [fileManager contentsOfDirectoryAtURL:diskCacheURL includingPropertiesForKeys:resourceKeys
                                                      options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    //获取子文件的属性
    NSMutableArray *cacheFiles = [NSMutableArray arrayWithArray:contents];
        [cacheFiles map:^id(NSURL *fileURL) {
            NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:nil];
            return RACTuplePack(fileURL, resourceValues);
    }];
    //子文件按修改时间排序
    [cacheFiles sortUsingComparator:^NSComparisonResult(RACTuple *obj1, RACTuple *obj2) {
        return [obj1.second[NSURLContentModificationDateKey] compare:obj2.second[NSURLContentModificationDateKey]];
    }];
    //开始删除
    for (RACTuple *tuple in cacheFiles) {
        totalSize -= [tuple.second[NSURLTotalFileAllocatedSizeKey] unsignedIntegerValue];
        [fileManager removeItemAtURL:tuple.first error:nil];
        if (totalSize <= self.retentionCacheSize) {
            break;
        }
    }
}


- (NSString *)pathForName:(NSString *)name {
    return [self.cachePath stringByAppendingPathComponent:name];
}


@end
