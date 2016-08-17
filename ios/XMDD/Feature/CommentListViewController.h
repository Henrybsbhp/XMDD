//
//  CommentListViewController.h
//  XiaoMa
//
//  Created by jt on 15-5-5.
//  Copyright (c) 2015年 huika. All rights reserved.
//

#import "JTTableViewController.h"

@interface CommentListViewController : JTTableViewController

///
@property (nonatomic, strong) NSNumber * shopid;
@property (nonatomic, assign) ShopServiceType serviceType;
@property (nonatomic, strong) NSArray * commentArray;

@end
