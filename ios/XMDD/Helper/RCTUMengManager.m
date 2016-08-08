//
//  RCTUMengManager.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/2.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "RCTUMengManager.h"
#import <UMMobClick/MobClick.h>

@implementation RCTUMengManager

RCT_EXPORT_MODULE()


RCT_EXPORT_METHOD(mobClick:(NSString *)event
                  attributes:(NSDictionary *)attrs) {
    [MobClick event:event attributes:attrs];
}

@end
