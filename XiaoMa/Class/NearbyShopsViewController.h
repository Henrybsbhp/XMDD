//
//  NearbyShopsViewController.h
//  XiaoMa
//
//  Created by jt on 15-4-22.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>

@interface NearbyShopsViewController : HKViewController<MAMapViewDelegate,AMapSearchDelegate>

@property (nonatomic)NSInteger type;

- (void)reloadBottomView;

@end
