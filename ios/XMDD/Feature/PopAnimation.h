//
//  PopAnimation.h
//  XiaoMa
//
//  Created by RockyYe on 16/4/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Price.h"
@interface PopAnimation : NSObject

+(void)animatedForLabel:(UILabel *)label fromValue:(CGFloat)fromValue toValue:(CGFloat) toValue andDuration:(NSTimeInterval)duration;

@end
