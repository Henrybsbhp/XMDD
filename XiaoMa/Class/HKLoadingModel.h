//
//  HKLoadingModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/6/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger
{
    HKLoadingTypeNone = 0,
    HKLoadingTypeReload = 0x01,
    HKLoadingTypeFirstTime = 0x02,
    HKLoadingTypeLoadMore = 0x04,
    HKLoadingTypeAll = NSUIntegerMax
}HKLoadingTypeMask;

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
@property (nonatomic, assign) BOOL isSectionLoadMore;
@property (nonatomic, assign) BOOL loadingSuccessForTheFirstTime;
@property (nonatomic, weak, readonly) id<HKLoadingModelDelegate> delegate;

///当前页码索引
@property (nonatomic, assign) NSUInteger currentPageIndex;

- (instancetype)initWithTargetView:(UIView *)targetView delegate:(id<HKLoadingModelDelegate>)delegate;

/***********以下方法将会触发delegate:"loadingModel:loadingDataSignalWithType:"**************/
- (void)loadDataForTheFirstTime;
- (void)reloadData;
- (void)loadMoreDataWithPromptView:(UIView *)view;
- (void)loadMoreDataIfNeededWithIndexPath:(NSIndexPath *)indexPath nest:(BOOL)nest promptView:(UIView *)view;
- (void)loadMoreDataIfNeededWithIndex:(NSInteger)index promptView:(UIView *)view;
///用section的判断方式
- (void)loadMoreDataIfNeededWithIndexPath:(NSIndexPath *)indexPath nestItemCount:(NSInteger)count promptView:(UIView *)view;

/***********以下方法不会触发delegate:"loadingModel:loadingDataSignalWithType:"**************/
- (void)autoLoadDataFromSignal:(RACSignal *)signal; //(将会自动调用reloadFromSignal:或loadForTheFirstTimeFromSignal:)
- (void)loadDataForTheFirstTimeFromSignal:(RACSignal *)signal;
- (void)reloadDataFromSignal:(RACSignal *)signal;
- (void)reloadDataWithDatasource:(NSArray *)datasource;

@end

@protocol HKLoadingModelDelegate <NSObject>

@optional
- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKLoadingTypeMask)type;
- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKLoadingTypeMask)type;
- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKLoadingTypeMask)type error:(NSError *)error;

- (void)loadingModel:(HKLoadingModel *)model didTappedForBlankPrompting:(NSString *)prompting type:(HKLoadingTypeMask)type;
- (void)loadingModel:(HKLoadingModel *)model didTappedForErrorPrompting:(NSString *)prompting type:(HKLoadingTypeMask)type;
- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKLoadingTypeMask)type;
- (void)loadingModel:(HKLoadingModel *)model didLoadingFailWithType:(HKLoadingTypeMask)type error:(NSError *)error;

- (NSArray *)loadingModel:(HKLoadingModel *)model datasourceFromLoadedData:(NSArray *)data withType:(HKLoadingTypeMask)type;
- (BOOL)loadingModel:(HKLoadingModel *)model shouldLoadMoreDataWithIndexPath:(NSIndexPath *)indexPath;
- (BOOL)loadingModelShouldAllowRefreshing:(HKLoadingModel *)model;
- (HKLoadingAnimationType)loadingAnimationTypeForTheFirstTimeWithLoadingModel:(HKLoadingModel *)model;

@end

