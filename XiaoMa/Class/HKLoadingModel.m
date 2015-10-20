//
//  HKLoadingModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/6/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKLoadingModel.h"
#import "UIView+DefaultEmptyView.h"
#import "UIView+JTLoadingView.h"
#import "UIScrollView+RefreshView.h"

#define kDebounchInterval       0.3

@interface HKLoadingModel ()
@end

@implementation HKLoadingModel
@synthesize datasource = _datasource;

- (instancetype)initWithTargetView:(UIView *)targetView delegate:(id<HKLoadingModelDelegate>)delegate
{
    self = [super init];
    if (self) {
        targetView.indicatorPoistionY = CGRectGetMidY(targetView.bounds)-40;
        _targetView = targetView;
        _delegate = delegate;
    }
    return self;
}

- (void)autoLoadDataFromSignal:(RACSignal *)signal
{
    if (self.loadingSuccessForTheFirstTime) {
        [self reloadDataFromSignal:signal];
    }
    else {
        [self loadDataForTheFirstTimeFromSignal:signal];
    }
}

- (void)loadDataForTheFirstTime
{
    RACSignal *signal;
    if ([self.delegate respondsToSelector:@selector(loadingModel:loadingDataSignalWithType:)]) {
        signal = [self.delegate loadingModel:self loadingDataSignalWithType:HKLoadingTypeFirstTime];
    }
    if (!signal) {
        signal = [RACSignal return:nil];
    }
    [self loadDataForTheFirstTimeFromSignal:signal];
}

- (void)loadDataForTheFirstTimeFromSignal:(RACSignal *)signal
{
    [[[[signal deliverOn:[RACScheduler mainThreadScheduler]] initially:^{

        _isLoading = YES;
        CKAsyncMainQueue(^{
            [self.targetView hideDefaultEmptyView];
            [self.targetView startActivityAnimationWithType:GifActivityIndicatorType];
        });
    }] finally:^{
        
        _isLoading = NO;
        CKAsyncMainQueue(^{
            [self.targetView stopActivityAnimation];
        });
    }] subscribeNext:^(NSArray *data) {
        
        _isRemain = data.count >= PageAmount;
        if ([self.delegate respondsToSelector:@selector(loadingModel:datasourceFromLoadedData:withType:)]) {
            self.datasource = [self.delegate loadingModel:self datasourceFromLoadedData:data withType:HKLoadingTypeFirstTime];
        }
        else {
            self.datasource = [NSMutableArray arrayWithArray:data];
        }
        if (data.count > 0) {
            BOOL allowRefeshing = YES;
            if ([self.delegate respondsToSelector:@selector(loadingModelShouldAllowRefreshing:)]) {
                allowRefeshing = [self.delegate loadingModelShouldAllowRefreshing:self];
            }
            if (allowRefeshing && [self.targetView isKindOfClass:[UIScrollView class]]) {
                //先移除所有事件
                [[(UIScrollView *)self.targetView refreshView] removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
                [[(UIScrollView *)self.targetView refreshView] addTarget:self
                                                                  action:@selector(reloadData)
                                                        forControlEvents:UIControlEventValueChanged];
            }
            self.loadingSuccessForTheFirstTime = YES;
            if ([self.delegate respondsToSelector:@selector(loadingModel:didLoadingSuccessWithType:)]) {
                [self.delegate loadingModel:self didLoadingSuccessWithType:HKLoadingTypeFirstTime];
            }
        }
        else {
            NSString *blank;
            if ([self.delegate respondsToSelector:@selector(loadingModel:blankPromptingWithType:)]) {
                blank = [self.delegate loadingModel:self blankPromptingWithType:HKLoadingTypeFirstTime];
            }
            @weakify(self);
            [self.targetView showDefaultEmptyViewWithText:blank tapBlock:^{

                @strongify(self);
                if ([self.delegate respondsToSelector:@selector(loadingModel:didTappedForBlankPrompting:type:)]) {
                    [self.delegate loadingModel:self didTappedForBlankPrompting:blank type:HKLoadingTypeFirstTime];
                }
                else {
                    [self loadDataForTheFirstTime];
                }
            }];
        }
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
        if ([self.delegate respondsToSelector:@selector(loadingModel:didLoadingFailWithType:error:)]) {
            [self.delegate loadingModel:self didLoadingFailWithType:HKLoadingTypeFirstTime error:error];
        }
        NSString *errorPrompting;
        if ([self.delegate respondsToSelector:@selector(loadingModel:errorPromptingWithType:error:)]) {
            errorPrompting = [self.delegate loadingModel:self errorPromptingWithType:HKLoadingTypeFirstTime error:error];
        }
        @weakify(self);
        [self.targetView showDefaultEmptyViewWithText:errorPrompting tapBlock:^{
            
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(loadingModel:didTappedForErrorPrompting:type:)]) {
                [self.delegate loadingModel:self didTappedForErrorPrompting:errorPrompting type:HKLoadingTypeFirstTime];
            }
            else {
                [self loadDataForTheFirstTime];
            }
        }];
    }];
}



- (void)reloadData
{
    RACSignal *signal;
    if ([self.delegate respondsToSelector:@selector(loadingModel:loadingDataSignalWithType:)]) {
        signal = [self.delegate loadingModel:self loadingDataSignalWithType:HKLoadingTypeReload];
    }
    if (!signal) {
        signal = [RACSignal return:nil];
    }
    [self reloadDataFromSignal:signal];
}

- (void)reloadDataWithDatasource:(NSArray *)datasource
{
    [self reloadDataFromSignal:[RACSignal return:datasource]];
}

- (void)reloadDataFromSignal:(RACSignal *)signal
{
    [[[[signal deliverOn:[RACScheduler mainThreadScheduler]] initially:^{
        
        _isLoading = YES;
        [self.targetView hideDefaultEmptyView];
        if ([self.targetView isKindOfClass:[UIScrollView class]]) {
            UIControl *control = [(UIScrollView *)self.targetView refreshView];
            if ([control actionsForTarget:self forControlEvent:UIControlEventValueChanged].count == 0) {
                [control addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
            }
        }
    }] finally:^{
        
        _isLoading = NO;
        if ([self.targetView isKindOfClass:[UIScrollView class]]) {
            [[(UIScrollView *)self.targetView refreshView]  endRefreshing];
        }
    }] subscribeNext:^(NSArray *data) {
        
        _isRemain = data.count >= PageAmount;
        if ([self.delegate respondsToSelector:@selector(loadingModel:datasourceFromLoadedData:withType:)]) {
            self.datasource = [self.delegate loadingModel:self datasourceFromLoadedData:data withType:HKLoadingTypeReload];
        }
        else {
            self.datasource = [NSMutableArray arrayWithArray:data];
        }
        
        if ([self.delegate respondsToSelector:@selector(loadingModel:didLoadingSuccessWithType:)]) {
            [self.delegate loadingModel:self didLoadingSuccessWithType:HKLoadingTypeReload];
        }
        if (data.count == 0) {
            NSString *blank;
            if ([self.delegate respondsToSelector:@selector(loadingModel:blankPromptingWithType:)]) {
                blank = [self.delegate loadingModel:self blankPromptingWithType:HKLoadingTypeReload];
            }
            @weakify(self);
            [self.targetView showDefaultEmptyViewWithText:blank tapBlock:^{
                
                @strongify(self);
                if ([self.delegate respondsToSelector:@selector(loadingModel:didTappedForBlankPrompting:type:)]) {
                    [self.delegate loadingModel:self didTappedForBlankPrompting:blank type:HKLoadingTypeReload];
                }
                else {
                    [self reloadData];
                }
            }];
        }
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
        if ([self.delegate respondsToSelector:@selector(loadingModel:didLoadingFailWithType:error:)]) {
            [self.delegate loadingModel:self didLoadingFailWithType:HKLoadingTypeReload error:error];
        }
    }];
}

- (void)loadMoreDataWithPromptView:(UIView *)view
{
    RACSignal *signal;
    if ([self.delegate respondsToSelector:@selector(loadingModel:loadingDataSignalWithType:)]) {
        signal = [self.delegate loadingModel:self loadingDataSignalWithType:HKLoadingTypeLoadMore];
    }
    if (!signal) {
        signal = [RACSignal return:nil];
    }
    [[[[signal deliverOn:[RACScheduler mainThreadScheduler]] initially:^{
        
        _isLoading = YES;
        [self.targetView hideDefaultEmptyView];
        [view startActivityAnimation];
    }] finally:^{
        
        _isLoading = NO;
        [view  stopActivityAnimation];
    }] subscribeNext:^(NSArray *data) {

        _isRemain = data.count >= PageAmount;

        if ([self.delegate respondsToSelector:@selector(loadingModel:datasourceFromLoadedData:withType:)]) {
            self.datasource = [self.delegate loadingModel:self datasourceFromLoadedData:data withType:HKLoadingTypeLoadMore];
        }
        else {
            [(NSMutableArray *)self.datasource safetyAddObjectsFromArray:data];
        }

        if ([self.delegate respondsToSelector:@selector(loadingModel:didLoadingSuccessWithType:)]) {
            [self.delegate loadingModel:self didLoadingSuccessWithType:HKLoadingTypeReload];
        }
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
        if ([self.delegate respondsToSelector:@selector(loadingModel:didLoadingFailWithType:error:)]) {
            [self.delegate loadingModel:self didLoadingFailWithType:HKLoadingTypeLoadMore error:error];
        }
    }];
}

- (void)loadMoreDataIfNeededWithIndexPath:(NSIndexPath *)indexPath nest:(BOOL)nest promptView:(UIView *)view
{
    if (!self.isRemain) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(loadingModel:shouldLoadMoreDataWithIndexPath:)]) {
        if(![self.delegate loadingModel:self shouldLoadMoreDataWithIndexPath:indexPath]) {
            return;
        }
    }
    else if (nest) {
        NSInteger index = indexPath.section > 0 ? indexPath.section : indexPath.row;
        if ([[self.datasource safetyObjectAtIndex:indexPath.section] count] > index+1) {
            return;
        }
    }
    else {
        NSInteger index =  indexPath.row + 1;
        if ([self.datasource count] > index) {
            return;
        }
    }
    [self loadMoreDataWithPromptView:view];
}


- (void)loadMoreDataIfNeededWithIndexPath:(NSIndexPath *)indexPath nestItemCount:(NSInteger)count promptView:(UIView *)view
{
    if (!self.isRemain) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(loadingModel:shouldLoadMoreDataWithIndexPath:)]) {
        if(![self.delegate loadingModel:self shouldLoadMoreDataWithIndexPath:indexPath]) {
            return;
        }
    }
    
    NSInteger index = self.isSectionLoadMore ? indexPath.section + 1 : indexPath.row + 1;
    if ([self.datasource count] > index) {
        return;
    }
    else
    {
        if (count) {
            NSInteger index =  indexPath.row + 1;
            if (count > index)
            {
                return;
            }
        }
    }
    [self loadMoreDataWithPromptView:view];
}
@end
