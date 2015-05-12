//
//  JTPhoneModel.h
//  Owner
//
//  Created by apple on 14-7-23.
//  Copyright (c) 2014年 tonpe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JTPhoneModel : NSObject

- (UIWebView *)makeCall:(NSString *)phoneNumber;
+ (void)makeCall:(NSString *)phoneNumber forTargetView:(UIView *)view;

@end
