//
//  JTTableView.h
//  JTReader
//
//  Created by jiangjunchen on 13-11-19.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTHeadRefreshView.h"
#import "UIView+JTLoadingView.h"

@class JTTableView;
@protocol JTTableViewDelegate;

@interface JTTableView : UITableView <SRRefreshDelegate>
@property (nonatomic, strong) JTHeadRefreshView *headRefreshView;
@property (nonatomic, strong) UIView *bottomLoadingView;
// REV @jiangjunchen name confuse
//@property (nonatomic, assign) id <JTTableViewDelegate> delegate;
///(Default is NO)
@property (nonatomic, assign) BOOL showHeadRefreshView;
///(Default is NO)
@property (nonatomic, assign) BOOL showBottomLoadingView;

@end

@protocol JTTableViewDelegate <NSObject, UITableViewDelegate>

@optional
- (void)tableViewDidStartRefresh:(JTTableView *)tableView;
@end


