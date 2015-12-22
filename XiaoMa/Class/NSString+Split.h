//
//  NSString+Split.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Split)

- (NSString *)splitByStep:(NSUInteger)step replacement:(NSString *)replacement;
- (NSString *)splitByStep:(NSUInteger)step replacement:(NSString *)replacement count:(NSUInteger)count;

@end
