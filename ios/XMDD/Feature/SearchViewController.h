//
//  SearchViewController.h
//  XiaoMa
//
//  Created by jt on 15-5-4.
//  Copyright (c) 2015年 huika. All rights reserved.
//

#import "HKTableViewController.h"

@interface SearchViewController : HKTableViewController<UISearchBarDelegate>

@property (nonatomic, assign) ShopServiceType serviceType;

@end
