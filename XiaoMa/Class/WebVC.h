//
//  WebVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebVC : UIViewController
@property (nonatomic, weak) UIViewController *originVC;

@property (nonatomic,copy)NSString * url;
@end
