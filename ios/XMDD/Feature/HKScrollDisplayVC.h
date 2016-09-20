//
//  HKScrollDisplayVC.h
//  XMDD
//
//  Created by RockyYe on 16/9/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>


@class HKScrollDisplayVC;

@protocol HKScrollDisplayVCDelegate <NSObject>

@optional
//当用户点击了某一页触发
- (void)scrollDisplayViewController:(HKScrollDisplayVC *)scrollDisplayViewController didSelectedIndex:(NSInteger)index;
//实时回传当前索引值
- (void)scrollDisplayViewController:(HKScrollDisplayVC *)scrollDisplayViewController currentIndex:(NSInteger)index;

@end


@interface HKScrollDisplayVC : UIViewController

@property (weak, nonatomic) id<HKScrollDisplayVCDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *controllers;
@property (strong, nonatomic) NSArray *adList;
@property (strong, nonatomic) UIPageViewController *pageVC;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (assign, nonatomic) NSInteger currentPage;
@property (nonatomic, assign) AdvertisementType adType;

@end
