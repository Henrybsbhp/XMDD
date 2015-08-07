//
//  ResultVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/8/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawingBoardView.h"

@interface ResultVC : UIViewController
@property (weak, nonatomic) IBOutlet DrawingBoardView *drawView;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end
