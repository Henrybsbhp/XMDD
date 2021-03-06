//
//  ReactView.m
//  XiaoMa
//
//  Created by jt on 16/2/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ReactView.h"

@implementation ReactView


- (void)rct_requestWithUrl:(NSURL *)url modulName:(NSString *)model properties:(NSDictionary *)properties
{
    if (self.rctRootView) {
        [self.rctRootView removeFromSuperview];
    }
    
    RCTRootView * rootView = [[RCTRootView alloc] initWithBundleURL:url
                                                         moduleName:model
                                                  initialProperties:properties
                                                      launchOptions:nil];
    [self addSubview:rootView];
    rootView.frame = self.bounds;
    
    self.rctRootView = rootView;
}

- (void)rct_requestWithUrl:(NSURL *)url andModulName:(NSString *)model
{
    [self rct_requestWithUrl:url modulName:model properties:nil];
}


@end
