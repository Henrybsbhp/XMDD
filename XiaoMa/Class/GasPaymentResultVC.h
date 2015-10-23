//
//  GasPaymentResultVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/19.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawingBoardView.h"
#import "GascardChargeOp.h"
#import "GasCard.h"

@interface GasPaymentResultVC : UITableViewController

@property (nonatomic, strong) NSString *detailText;
@property (nonatomic, assign) DrawingBoardViewStatus drawingStatus;
@property (nonatomic, strong) GascardChargeOp *gasPayOp;
@property (nonatomic, assign) GasCard *gasCard;
@property (nonatomic, weak) UIViewController *originVC;

@end
