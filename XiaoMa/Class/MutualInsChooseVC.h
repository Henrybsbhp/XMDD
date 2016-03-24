//
//  MutualInsChooseVC.h
//  XiaoMa
//
//  Created by jt on 16/3/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKViewController.h"

@interface MutualInsChooseVC : HKViewController
@property (nonatomic, weak) UIViewController *originVC;
@property (nonatomic, strong) NSNumber *memberId;
@property (nonatomic, strong) NSNumber *groupId;
@property (nonatomic, strong) NSString *groupName;

@end
