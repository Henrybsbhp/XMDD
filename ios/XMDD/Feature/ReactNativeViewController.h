//
//  HKReactNativeViewController.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReactView.h"
#import "HKNavigationBar.h"

@interface ReactNativeViewController : UIViewController

- (instancetype)initWithHref:(NSString *)href properties:(NSDictionary *)properties;

@property (strong, nonatomic) ReactView *rctView;
@property (nonatomic, strong, readonly) NSString *href;

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated;

@end
