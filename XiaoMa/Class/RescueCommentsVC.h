//
//  RescueCommentsVC.h
//  XiaoMa
//
//  Created by baiyulin on 15/12/10.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HKRescueHistory;
@interface RescueCommentsVC : UIViewController

@property (nonatomic,strong)HKRescueHistory * history;
@property (nonatomic, strong)   NSNumber    * applyType;//1.救援 2.协办
@end
