//
//  DetailsAlertVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/8/19.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsAlertVC : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *detailsImageView;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

+ (DetailsAlertVC *)showInTargetVC:(UIViewController *)targetVC withType:(NSInteger)type;
@end
