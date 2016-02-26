//
//  SuspendedAdVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 16/2/24.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKAdvertisement.h"
#import "SYPaginator.h"

@protocol SuspendedAdClickDelegate <NSObject>

@optional

- (void)adClick;

@end

@interface SuspendedAdVC : NSObject

@property (nonatomic, strong, readonly) SYPaginatorView *adView;
@property (nonatomic, strong, readonly) NSString *mobBaseEvent;
@property (nonatomic, weak, readonly)   UIViewController *targetVC;

@property (nonatomic, strong) NSArray *adList;

@property (nonatomic, weak) id <SuspendedAdClickDelegate> clickDelegate;

+ (instancetype)adVCWithBoundsWidth:(CGFloat)width
                    targetVC:(UIViewController *)vc mobBaseEvent:(NSString *)event;

@end
