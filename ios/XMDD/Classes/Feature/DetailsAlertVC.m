//
//  DetailsAlertVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/8/19.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "DetailsAlertVC.h"

typedef NS_ENUM(NSInteger, benefitType) {
    CarWashBenefitType = 0,
    RescueBenefitType,
    AgencyBenefitType
};

@interface DetailsAlertVC ()

@end

@implementation DetailsAlertVC

- (void)dealloc
{
    DebugLog(@"DetailsAlertVC dealloc!");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (DetailsAlertVC *)showInTargetVC:(UIViewController *)targetVC withType:(NSInteger)type
{
    DetailsAlertVC *vc = [UIStoryboard vcWithId:@"DetailsAlertVC" inStoryboard:@"Bank"];
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.presentedFormSheetSize = CGSizeMake(290, 360);
    formSheet.cornerRadius = 2.0;
    formSheet.shadowOpacity = 0.01;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.shouldCenterVertically = YES;
    if (type == CarWashBenefitType) {
        vc.detailsImageView.image = [UIImage imageNamed:@"mb_carwashdetail"];
    }
    else if (type == RescueBenefitType) {
        vc.detailsImageView.image = [UIImage imageNamed:@"mb_rescuedetail"];
    }
    else {
        vc.detailsImageView.image = [UIImage imageNamed:@"mb_agencydetail"];
    }
    [targetVC mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
    
    @weakify(formSheet);
    [[[vc.confirmBtn rac_signalForControlEvents:UIControlEventTouchUpInside] take:1] subscribeNext:^(id x) {
        @strongify(formSheet);
        [formSheet dismissAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
            
        }];
    }];
    
    return vc;
}

@end
