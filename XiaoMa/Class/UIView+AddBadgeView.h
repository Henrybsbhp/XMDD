//
//  UIView+AddBadgeView.h
//  JTNewReader
//
//  Created by jiangjunchen on 14-4-3.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTImageBadge.h"

@interface UIView (AddBadgeView)
@property (nonatomic, strong) JTImageBadge *badgeView;
- (BOOL)hasBadgeView;

@end
