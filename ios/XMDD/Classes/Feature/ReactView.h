//
//  ReactView.h
//  XiaoMa
//
//  Created by jt on 16/2/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCTRootView.h"


@interface ReactView : UIView

- (void)rct_requestWithUrl:(NSURL *)url andModulName:(NSString *)model;
- (void)rct_requestWithUrl:(NSURL *)url modulName:(NSString *)model properties:(NSDictionary *)properties;

@end
