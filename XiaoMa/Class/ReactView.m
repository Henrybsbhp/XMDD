//
//  ReactView.m
//  XiaoMa
//
//  Created by jt on 16/2/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ReactView.h"

@interface ReactView()

@property (nonatomic,strong)RCTRootView * rctRootView;

@end

@implementation ReactView

- (void)initialize
{
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)rct_requestWithUrl:(NSURL *)url andModulName:(NSString *)model;
{
    if (self.rctRootView)
    {
        [self.rctRootView removeFromSuperview];
    }
    
    RCTRootView * rootView = [[RCTRootView alloc] initWithBundleURL:url
                                                   moduleName:model
                                                  initialProperties:nil
                                                      launchOptions:nil];
    [self addSubview:rootView];
    rootView.frame = self.bounds;
    
    
    self.rctRootView = rootView;
}


@end
