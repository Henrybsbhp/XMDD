//
//  AwardOtherSheetVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/27.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "AwardOtherSheetVC.h"

@interface AwardOtherSheetVC ()

@property (weak, nonatomic) IBOutlet UIView *successView;
@property (weak, nonatomic) IBOutlet UIView *failureView;

@end

@implementation AwardOtherSheetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.successView.hidden = !self.isSuccess;
    self.failureView.hidden = self.isSuccess;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
