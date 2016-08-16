//
//  ShopCommentListVC.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/16.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKViewController.h"

@interface ShopCommentListVC : HKViewController

@property (nonatomic, strong) NSNumber * shopID;
@property (nonatomic, assign) ShopServiceType serviceType;
@property (nonatomic, strong) NSArray * commentArray;

@end
