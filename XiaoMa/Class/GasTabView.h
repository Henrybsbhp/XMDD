//
//  GasTabView.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GasTabView : UIView
@property (nonatomic, copy) void (^tabBlock)(NSInteger index);
@end
