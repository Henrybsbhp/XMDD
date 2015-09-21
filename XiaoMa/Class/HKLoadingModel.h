//
//  HKLoadingModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/6/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger
{
    HKDatasourceLoadingTypeReloadData = 0,
    HKDatasourceLoadingTypeFirstTime,
    HKDatasourceLoadingTypeLoadMore
}HKDatasourceLoadingType;

typedef enum : NSInteger
{
    HKLoadingAnimationTypeNone = 0,
    HKLoadingAnimationTypeGif,
    HKLoadingAnimationTypeRefresh
}HKLoadingAnimationType;

@protocol HKLoadingModelDelegate;

@interface HKLoadingModel : NSObject
@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic, strong, readonly) UIView *targetView;
@property (nonatomic, assign, readonly) BOOL isRemain;
@property (nonatomic, assign, readonly) BOOL isLoading;
@property (nonatomic, weak, readonly) id<HKLoadingModelDelegate> delegate;

- (instancetype)initWithTargetView:(UIView *)targetView delegate:(id<HKLoadingModelDelegate>)delegate;
- (void)loadDataForTheFirstTime;
- (void)reloadData;
- (void)reloadDataWithDatasource:(NSArray *)datasource;
- (void)loadMoreDataWithPromptView:(UIView *)view;
- (void)loadMoreDataIfNeededWithIndexPath:(NSIndexPath *)indexPath nest:(BOOL)nest promptView:(UIView *)view;

@end

@protocol HKLoadingModelDelegate <NSObject>

@optional
- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKDatasourceLoadingType)type;
- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKDatasourceLoadingType)type;
- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKDatasourceLoadingType)type error:(NSError *)error;

- (void)loadingModel:(HKLoadingModel *)model didTappedForBlankPrompting:(NSString *)prompting type:(HKDatasourceLoadingType)type;
- (void)loadingModel:(HKLoadingModel *)model didTappedForErrorPrompting:(NSString *)prompting type:(HKDatasourceLoadingType)type;
- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKDatasourceLoadingType)type;
- (void)loadingModel:(HKLoadingModel *)model didLoadingFailWithType:(HKDatasourceLoadingType)type error:(NSError *)error;

- (NSArray *)loadingModel:(HKLoadingModel *)model datasourceFromLoadedData:(NSArray *)data withType:(HKDatasourceLoadingType)type;
- (BOOL)loadingModel:(HKLoadingModel *)model shouldLoadMoreDataWithIndexPath:(NSIndexPath *)indexPath;
- (BOOL)loadingModelShouldAllowRefreshing:(HKLoadingModel *)model;
- (HKLoadingAnimationType)loadingAnimationTypeForTheFirstTimeWithLoadingModel:(HKLoadingModel *)model;

@end

