//
//  UIScrollView+RefreshView.h
//  XiaoNiuClient
//
//  Created by jiangjunchen on 14-6-4.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTHeadRefreshView.h"

@interface UIScrollView (RefreshView)<SRRefreshDelegate>

@property (nonatomic, strong) JTHeadRefreshView *refreshHeaderView;

@end
