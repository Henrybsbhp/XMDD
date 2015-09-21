//
//  NSString+Safe.h
//  XiaoMa
//
//  Created by jt on 15/9/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Safe)

- (NSString * )safteySubstringFromIndex:(NSInteger)i;
- (NSString * )safteySubstringToIndexIndex:(NSInteger)i;

@end
