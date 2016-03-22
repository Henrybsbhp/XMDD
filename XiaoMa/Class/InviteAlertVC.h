//
//  InviteAlertVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/16.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKAlertVC.h"

typedef enum : NSUInteger {
    InviteAlertTypeNologin  = 0,  
    InviteAlertTypeJoin     = 1,
    InviteAlertTypeCopyCode = 2
} InviteAlertType;

@interface InviteAlertVC : HKAlertVC

@property (nonatomic, assign)InviteAlertType alertType;

@property (nonatomic, strong)NSString * groupName;

@property (nonatomic, strong)NSString * leaderName;

@end
