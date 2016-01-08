//
//  ResultVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/8/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawingBoardView.h"

@interface ResultVC : HKViewController
@property (weak, nonatomic) IBOutlet DrawingBoardView *drawView;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

+ (ResultVC *)showInTargetVC:(UIViewController *)targetVC withSuccessText:(NSString *)success ensureBlock:(void(^)(void))block;

@end
