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

- (void)dealloc
{
    
}

- (void)loadDataForTheFirstTime
{
    RACSignal *signal;
    if ([self.delegate respondsToSelector:@selector(loadingModel:loadingDataSignalWithType:)]) {
        signal = [self.delegate loadingModel:self loadingDataSignalWithType:HKDatasourceLoadingTypeFirstTime];
    }
    if (!signal) {
        signal = [RACSignal return:nil];
    }
    [[[signal initially:^{

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
            self.datasource = [self.delegate loadingModel:self datasourceFromLoadedData:data withType:HKDatasourceLoadingTypeFirstTime];
        }
        else {
            self.datasource = [NSMutableArray arrayWithArray:data];
        }
        if (data.count > 0) {
            if ([self.targetView isKindOfClass:[UIScrollView class]]) {
                [[(UIScrollView *)self.targetView refreshView] addTarget:self
                                                                  action:@selector(reloadData)
                                                        forControlEvents:UIControlEventValueChanged];
            }
            if ([self.delegate respondsToSelector:@selector(loadingModel:didLoadingSuccessWithType:)]) {
                [self.delegate loadingModel:self didLoadingSuccessWithType:HKDatasourceLoadingTypeFirstTime];
            }
        }
        else {
            NSString *blank;
            if ([self.delegate respondsToSelector:@selector(loadingModel:blankPromptingWithType:)]) {
                blank = [self.delegate loadingModel:self blankPromptingWithType:HKDatasourceLoadingTypeFirstTime];
            }
            @weakify(self);
            [self.targetView showDefaultEmptyViewWithText:blank tapBlock:^{

                @strongify(self);
                if ([self.delegate respondsToSelector:@selector(loadingModel:didTappedForBlankPrompting:type:)]) {
                    [self.delegate loadingModel:self didTappedForBlankPrompting:blank type:HKDatasourceLoadingTypeFirstTime];
                }
                else {
                    [self loadDataForTheFirstTime];
                }
            }];
        }
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
        NSString *errorPrompting;
        if ([self.delegate respondsToSelector:@selector(loadingModel:errorPromptingWithType:)]) {
            errorPrompting = [self.delegate loadingModel:self errorPromptingWithType:HKDatasourceLoadingTypeFirstTime];
        }
        @weakify(self);
        [self.targetView showDefaultEmptyViewWithText:errorPrompting tapBlock:^{
            
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(loadingModel:didTappedForErrorPrompting:type:)]) {
                [self.delegate loadingModel:self didTappedForErrorPrompting:errorPrompting type:HKDatasourceLoadingTypeFirstTime];
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
        signal = [self.delegate loadingModel:self loadingDataSignalWithType:HKDatasourceLoadingTypeReloadData];
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
    [[[signal initially:^{
        
        _isLoading = YES;
        [self.targetView hideDefaultEmptyView];
    }] finally:^{
        
        _isLoading = NO;
        if ([self.targetView isKindOfClass:[UIScrollView class]]) {
            [[(UIScrollView *)self.targetView refreshView]  endRefreshing];
        }
    }] subscribeNext:^(NSArray *data) {
        
        _isRemain = data.count >= PageAmount;
        if ([self.delegate respondsToSelector:@selector(loadingModel:datasourceFromLoadedData:withType:)]) {
            self.datasource = [self.delegate loadingModel:self datasourceFromLoadedData:data withType:HKDatasourceLoadingTypeReloadData];
        }
        else {
            self.datasource = [NSMutableArray arrayWithArray:data];
        }
        
        if ([self.delegate respondsToSelector:@selector(loadingModel:didLoadingSuccessWithType:)]) {
            [self.delegate loadingModel:self didLoadingSuccessWithType:HKDatasourceLoadingTypeReloadData];
        }
        if (data.count == 0) {
            NSString *blank;
            if ([self.delegate respondsToSelector:@selector(loadingModel:blankPromptingWithType:)]) {
                blank = [self.delegate loadingModel:self blankPromptingWithType:HKDatasourceLoadingTypeReloadData];
            }
            @weakify(self);
            [self.targetView showDefaultEmptyViewWithText:blank tapBlock:^{
                
                @strongify(self);
                if ([self.delegate respondsToSelector:@selector(loadingModel:didTappedForBlankPrompting:type:)]) {
                    [self.delegate loadingModel:self didTappedForBlankPrompting:blank type:HKDatasourceLoadingTypeReloadData];
                }
                else {
                    [self reloadData];
                }
            }];
        }
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

- (void)loadMoreDataWithPromptView:(UIView *)view
{
    RACSignal *signal;
    if ([self.delegate respondsToSelector:@selector(loadingModel:loadingDataSignalWithType:)]) {
        signal = [self.delegate loadingModel:self loadingDataSignalWithType:HKDatasourceLoadingTypeLoadMore];
    }
    if (!signal) {
        signal = [RACSignal return:nil];
    }
    [[[signal initially:^{
        
        _isLoading = YES;
        [self.targetView hideDefaultEmptyView];
        [view startActivityAnimation];
    }] finally:^{
        
        _isLoading = NO;
        [view  stopActivityAnimation];
    }] subscribeNext:^(NSArray *data) {

        _isRemain = data.count >= PageAmount;

        if ([self.delegate respondsToSelector:@selector(loadingModel:datasourceFromLoadedData:withType:)]) {
            self.datasource = [self.delegate loadingModel:self datasourceFromLoadedData:data withType:HKDatasourceLoadingTypeReloadData];
        }
        else {
            [(NSMutableArray *)self.datasource safetyAddObjectsFromArray:data];
        }

        if ([self.delegate respondsToSelector:@selector(loadingModel:didLoadingSuccessWithType:)]) {
            [self.delegate loadingModel:self didLoadingSuccessWithType:HKDatasourceLoadingTypeReloadData];
        }
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
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
        if ([self.datasource count] > indexPath.row+1) {
            return;
        }
    }
    [self loadMoreDataWithPromptView:view];
}

@end
