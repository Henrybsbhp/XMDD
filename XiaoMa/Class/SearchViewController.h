//
//  SearchViewController.h
//  XiaoMa
//
//  Created by jt on 15-5-4.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic)NSInteger searchType;

@end
