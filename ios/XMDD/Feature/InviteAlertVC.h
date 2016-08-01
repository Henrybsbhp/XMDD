//
//  InviteAlertVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/16.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKAlertVC.h"

typedef enum : NSUInteger {
    InviteAlertTypeNologin     = 0,
    InviteAlertTypeJoin        = 1,
    InviteAlertTypeCopyCode    = 2,
    InviteAlertTypeGotoWechat  = 3
} InviteAlertType;

typedef enum : NSUInteger {
    GroupTypeByself        = 1,
    GroupTypeAutoGroup     = 2
} GroupType;

@interface InviteAlertVC : HKAlertVC

@property (nonatomic, assign)InviteAlertType alertType;

@property (nonatomic, strong)NSString * groupName;

@property (nonatomic, assign)GroupType groupType;

@property (nonatomic, strong)NSString * leaderName;

//分享口令到微信类型（InviteAlertTypeGotoWechat）必填
@property (nonatomic, strong)NSString * contentStr;

@end
