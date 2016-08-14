//
//  HKImageAlertVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/21.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKAlertVC.h"

@interface HKImageAlertVC : HKAlertVC

@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *topTitle;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSAttributedString *attributedMessage;
///(default is top:35,left:25,right:25,bottom:35)
@property (nonatomic, assign) UIEdgeInsets contentInsets;

// 返回HKImageAlertVC的工厂方法
+(HKImageAlertVC *)alertWithTopTitle:(NSString *)topTitle ImageName:(NSString *)imageName Message:(NSString *)message ActionItems:(NSArray *)actionItems;

// Message 为 NSAttributedString
+ (HKImageAlertVC *)alertWithTopTitle:(NSString *)topTitle ImageName:(NSString *)imageName attributedMessage:(NSAttributedString *)attributedMessage ActionItems:(NSArray *)actionItems;

@end
