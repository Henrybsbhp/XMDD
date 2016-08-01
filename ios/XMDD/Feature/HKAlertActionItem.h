//
//  HKAlertActionItem.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/4/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKAlertActionItem : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, copy) void(^clickBlock)(id alertVC);

+ (instancetype)item;
///(default color is HEXCOLOR(@"#18d06a"), clickBlock is nil)
+ (instancetype)itemWithTitle:(NSString *)title;
+ (instancetype)itemWithTitle:(NSString *)title color:(UIColor *)color clickBlock:(void(^)(id alertVC))block;

@end

