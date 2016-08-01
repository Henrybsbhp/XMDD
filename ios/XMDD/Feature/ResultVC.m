//
//  ResultVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/8/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "ResultVC.h"

@interface ResultVC ()

@end

@implementation ResultVC

- (void)dealloc
{
    DebugLog(@"ResultVC dealloc!");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

+ (ResultVC *)showInTargetVC:(UIViewController *)targetVC withSuccessText:(NSString *)success ensureBlock:(void(^)(void))block
{
    ResultVC *vc = [UIStoryboard vcWithId:@"ResultVC" inStoryboard:@"Bank"];
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.presentedFormSheetSize = CGSizeMake(280, 238);
    formSheet.cornerRadius = 2.0;
    formSheet.shadowOpacity = 0.01;
    formSheet.shouldDismissOnBackgroundViewTap = NO;
    formSheet.shouldCenterVertically = YES;
    [targetVC mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        [vc.drawView drawSuccess];
        vc.textLabel.text = success;
    }];
    
    @weakify(formSheet);
    [[[vc.confirmBtn rac_signalForControlEvents:UIControlEventTouchUpInside] take:1] subscribeNext:^(id x) {
        @strongify(formSheet);
        [formSheet dismissAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
            if (block) {
                block();
            }
        }];
    }];
    
    return vc;
}

@end
