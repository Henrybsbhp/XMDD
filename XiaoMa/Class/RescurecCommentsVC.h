//
//  RescurecCommentsVC.h
//  XiaoMa
//
//  Created by baiyulin on 15/12/10.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKRescueHistory.h"

@interface RescurecCommentsVC : UIViewController

@property (nonatomic,strong)HKRescueHistory * history;
@property (nonatomic, assign)   NSInteger       isLog;//是否已评价
@property (nonatomic, strong)   NSNumber    *   applyType;//1.救援 2.协办
@end
