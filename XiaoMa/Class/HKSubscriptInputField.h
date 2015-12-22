//
//  HKSubscriptTextField.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/8.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKLimitTextField.h"

@interface HKSubscriptInputField : UIView
@property (nonatomic, strong) CKLimitTextField *inputField;
@property (nonatomic, strong) NSString *subscriptImageName;

@end
