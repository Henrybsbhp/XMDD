//
//  RCTHKWebView.h
//  XMDD
//
//  Created by jiangjunchen on 16/10/13.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "RCTWebView.h"

@interface RNWebView : RCTWebView
@property (nonatomic, copy) RCTBubblingEventBlock onHandleLink;
@end
