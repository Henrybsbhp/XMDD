//
//  HKFileCache.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/25.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKFileCache : NSObject
@property (nonatomic, assign) NSUInteger maxCacheSize;
@property (nonatomic, assign) NSUInteger retentionCacheSize;
@property (nonatomic, strong, readonly) NSString *cachePath;

- (instancetype)initWithCachePath:(NSString *)cachePath;
- (void)cleanDisk;
- (NSString *)pathForName:(NSString *)name;

@end
