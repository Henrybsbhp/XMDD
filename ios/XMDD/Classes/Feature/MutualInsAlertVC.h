//
//  MutualInsAlertView.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKAlertVC.h"
@class MutualInsAlertVCItem;

@interface MutualInsAlertVC : HKAlertVC

@property (nonatomic, strong) NSString *topTitle;
@property (nonatomic, strong) NSArray *items;

@end

@interface MutualInsAlertVCItem : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detailTitle;
@property (nonatomic, strong) UIColor *detailTitleColor;

+ (instancetype)itemWithTitle:(NSString *)title detailTitle:(NSString *)detailTitle detailColor:(UIColor *)detailColor;

@end