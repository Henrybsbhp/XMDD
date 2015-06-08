//
//  NearbyShopListVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/30.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "NearbyShopListVC.h"

@interface NearbyShopListVC ()

@end

@implementation NearbyShopListVC

- (void)viewDidLoad {
    
    self.forbidAD = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSString * deallocInfo = [NSString stringWithFormat:@"%@ dealloc~~",NSStringFromClass([self class])];
    DebugLog(deallocInfo);
}

- (void)reloadDataWithText:(NSString *)text error:(NSError *)error
{
    if (!error) {
        text = @"附近暂无商户";
    }
    [super reloadDataWithText:text error:error];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
