//
//  HKLoadingHelper.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKLoadingHelper.h"

@implementation HKLoadingHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pageAmount = 10;
    }
    return self;
}

+ (instancetype)loadingHelperWithPageAmount:(NSInteger)pageAmount {
    HKLoadingHelper *helper = [[self alloc] init];
    helper.pageAmount = pageAmount;
    return helper;
}

- (BOOL)canLoadMoreForDatasource:(CKList *)datasource atRow:(NSInteger)row {
    NSInteger count = datasource.count;
    return !self.isLoading && self.isRemain && count > 0 && count % self.pageAmount == 0 && row == count - 1;
}

- (BOOL)canLoadMoreForDatasource:(CKList *)datasource atSection:(NSInteger)section andRow:(NSInteger)row {
    if (section == datasource.count) {
        NSInteger count = [datasource[section] count];
        return !self.isLoading && self.isRemain && count > 0 && count % self.pageAmount == 0 && row == count - 1;
    }
    return NO;
}

@end
