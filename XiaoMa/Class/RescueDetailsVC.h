//
//  RescueDetailsVC.h
//  XiaoMa
//
//  Created by baiyulin on 15/12/11.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ADViewController;
@interface RescueDetailsVC : UIViewController
@property (nonatomic, assign) NSInteger           type;//救援类型
@property (nonatomic, copy)   NSString          * titleStr;
@property (nonatomic, strong) ADViewController  * adctrl;
@end
