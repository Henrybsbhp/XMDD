//
//  CollectionChooseVC.h
//  XiaoMa
//
//  Created by jt on 15/8/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionChooseVC : HKViewController

@property(nonatomic,strong)void(^selectAction)(id);

@property(nonatomic,strong)NSArray * datasource;

@end
