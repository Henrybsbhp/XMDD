//
//  NSObject+AutoConvertValue.h
//  XiaoNiuShared
//
//  Created by jiangjunchen on 14-7-20.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NSObjectAutoConvertValueDelegate <NSObject>

- (float)floatValue;
- (NSInteger)integerValue;
- (double)doubleValue;
- (int)intValue;
- (BOOL)boolValue;

@end

@interface NSObject (AutoConvertValue)<NSObjectAutoConvertValueDelegate>


@end
