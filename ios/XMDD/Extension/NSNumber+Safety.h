//
//  NSNumber+Safety.h
//  XiaoMa
//
//  Created by fuqi on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (Safety)

- (BOOL)safetyEqualToNumber:(NSNumber *)number;

@end
