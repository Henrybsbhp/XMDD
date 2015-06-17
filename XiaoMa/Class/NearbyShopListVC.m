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

- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKDatasourceLoadingType)type
{
    return @"附近暂无商户";
}


@end
