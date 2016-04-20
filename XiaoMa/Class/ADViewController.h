//
//  ADViewController.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKAdvertisement.h"
#import "SYPaginator.h"


@interface ADViewController : NSObject

@property (nonatomic, strong, readonly) SYPaginatorView *adView;
@property (nonatomic, assign, readonly) AdvertisementType adType;
@property (nonatomic, strong, readonly) NSArray *adList;
@property (nonatomic, strong, readonly) NSString *mobBaseEvent;
@property (nonatomic, strong, readonly) NSDictionary *mobBaseEventDict;
@property (nonatomic, weak, readonly) UIViewController *targetVC;


+ (instancetype)vcWithADType:(AdvertisementType)type boundsWidth:(CGFloat)width
                    targetVC:(UIViewController *)vc mobBaseEvent:(NSString *)event
                    mobBaseEventDict:(NSDictionary *)dict;

///reload
- (void)reloadDataWithForce:(BOOL)force completed:(void(^)(ADViewController *ctrl, NSArray *ads))completed;
- (void)reloadDataForTableView:(UITableView *)tableView;

@end
