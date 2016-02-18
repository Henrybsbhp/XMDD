//
//  ReactView.h
//  XiaoMa
//
//  Created by jt on 16/2/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKView.h"
#import <RCTRootView.h>

@interface ReactView : HKView

- (void)rct_requestWithUrlStr:(NSString *)urlStr;

@end
