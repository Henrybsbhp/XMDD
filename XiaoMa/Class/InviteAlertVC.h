//
//  InviteAlertVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/16.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKAlertVC.h"

typedef enum : NSUInteger {
    InviteAlertTypeCopy = 1,
    InviteAlertTypeJoin = 2
} InviteAlertType;

@interface InviteAlertVC : HKAlertVC

@property (nonatomic, assign)InviteAlertType alertType;



@end
