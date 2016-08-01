//
//  NSMutableDictionary+AddParams.h
//  XiaoNiuShared
//
//  Created by jiangjunchen on 14-6-23.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKKit.h"

@interface NSDictionary (GetParams)
- (id<NSObjectAutoConvertValueDelegate>)paramForName:(NSString *)name;
- (float)floatParamForName:(NSString *)name;
- (NSInteger)integerParamForName:(NSString *)name;
- (double)doubleParamForName:(NSString *)name;
- (int)intParamForName:(NSString *)name;
- (BOOL)boolParamForName:(NSString *)name;
- (NSString *)stringParamForName:(NSString *)name;
- (NSNumber *)numberParamForName:(NSString *)name;

@end

@interface NSMutableDictionary (AddParams)

- (void)addParam:(id)param forName:(NSString *)name;
- (id)firstParam;

@end
