//
//  HKMessageAlertVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/25.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKAlertVC.h"

@interface HKMessageAlertVC : HKAlertVC
///(default font=14, color='#888888')
@property (nonatomic, strong, readonly) UILabel *messageLabel;
///(default is top:35,left:25,right:25,bottom:35)
@property (nonatomic, assign) UIEdgeInsets contentInsets;
///(default is 135)
@property (nonatomic, assign) CGFloat minMessageContentViewHeight;
@end
