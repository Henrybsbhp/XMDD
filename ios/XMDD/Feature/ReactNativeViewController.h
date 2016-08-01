//
//  HKReactNativeViewController.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReactView.h"

@interface ReactNativeViewController : UIViewController

- (instancetype)initWithModuleName:(NSString *)moduleName properties:(NSDictionary *)properties;

@property (strong, nonatomic) ReactView *rctView;
@property (nonatomic, strong, readonly) NSString * modulName;

@end
