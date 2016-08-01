//
//  JTTableView.h
//  JTReader
//
//  Created by jiangjunchen on 13-11-19.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+JTLoadingView.h"

@class JTTableView;
@protocol JTTableViewDelegate;

@interface JTTableView : UITableView
@property (nonatomic, strong) UIView *bottomLoadingView;
///(Default is NO)
@property (nonatomic, assign) BOOL showBottomLoadingView;

@end

@protocol JTTableViewDelegate <NSObject, UITableViewDelegate>

@optional
- (void)tableViewDidStartRefresh:(JTTableView *)tableView;
@end


