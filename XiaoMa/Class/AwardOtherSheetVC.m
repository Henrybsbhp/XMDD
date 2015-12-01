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
@property (weak, nonatomic) IBOutlet UIView *alreadygetView;

@end

@implementation AwardOtherSheetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.sheetType == AwardSheetTypeSuccess) {
        self.successView.hidden = NO;
        self.failureView.hidden = YES;
        self.alreadygetView.hidden = YES;
    }
    else if (self.sheetType == AwardSheetTypeAlreadyget) {
        self.successView.hidden = YES;
        self.failureView.hidden = YES;
        self.alreadygetView.hidden = NO;
    }
    else {
        self.successView.hidden = YES;
        self.failureView.hidden = NO;
        self.alreadygetView.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
