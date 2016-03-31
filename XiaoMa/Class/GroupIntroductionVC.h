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

typedef enum : NSUInteger {
    BtnTypeNotStart,
    BtnTypeJoinNow,
    BtnTypeAlready,
    BtnTypeEnded
} DetailBtnType;

@interface GroupIntroductionVC : HKViewController

@property (nonatomic, weak) UIViewController *originVC;

@property (nonatomic, strong) NSString * titleStr;
@property (nonatomic, assign) MutualGroupType groupType;
@property (nonatomic, assign) DetailBtnType btnType;
@property (nonatomic, strong) NSNumber * groupId;
@property (nonatomic, strong) NSString *memberId;
@property (nonatomic, strong) NSString *groupName;

@end
