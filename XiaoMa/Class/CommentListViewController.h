//
//  CommentListViewController.h
//  XiaoMa
//
//  Created by jt on 15-5-5.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "JTTableViewController.h"

@interface CommentListViewController : JTTableViewController

///
@property (nonatomic,copy)NSString * shopid;

@property (nonatomic,strong)NSArray * commentArray;

@end
