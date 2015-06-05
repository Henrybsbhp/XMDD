//
//  NSString+Safety.h
//  JTNewReader
//
//  Created by jiangjunchen on 14-3-18.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Safety)

+ (NSString *)safetyStringWithString:(NSString *)aString;
+ (NSString *)stringNotNullFrom:(NSString *)string;
@end

@interface NSMutableString (Safety)

- (void)safetyAppendString:(NSString *)aString;
@end
