//
//  GroupIntroductionVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    MutualGroupTypeSystem,
    MutualGroupTypeSelf,
} MutualGroupType;


/// 团介绍页面
@interface GroupIntroductionVC : HKViewController

@property (nonatomic, weak) UIViewController *originVC;

@property (nonatomic, assign) MutualGroupType groupType;
@property (nonatomic, strong) NSString *groupIntrUrlStr;


@end
