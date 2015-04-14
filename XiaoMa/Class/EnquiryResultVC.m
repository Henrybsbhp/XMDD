//
//  EnquiryResultVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/12.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "EnquiryResultVC.h"
#import "XiaoMa.h"
#import "UploadInfomationVC.h"

@interface EnquiryResultVC ()

@end

@implementation EnquiryResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionUploadInfomation:(id)sender
{
    UploadInfomationVC *vc = [UIStoryboard vcWithId:@"UploadInfomationVC" inStoryboard:@"Insurance"];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - Table view data source

@end
