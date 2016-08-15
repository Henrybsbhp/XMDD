//
//  HKLoadingHelper.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    HKLoadStatusSuccess = 0,
    HKLoadStatusLoading = 1,
    HKLoadStatusError = 2
}HKLoadStatus;

@interface HKLoadingHelper : NSObject
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isRemain;
@property (nonatomic, assign) NSInteger pageAmount;

+ (instancetype)loadingHelperWithPageAmount:(NSInteger)pageAmount;

- (BOOL)canLoadMoreForDatasource:(CKList *)datasource atRow:(NSInteger)row;
- (BOOL)canLoadMoreForDatasource:(CKList *)datasource atSection:(NSInteger)section andRow:(NSInteger)row;

@end
