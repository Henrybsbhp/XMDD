//
//  RCTLoadingView.h
//  XMDD
//
//  Created by jiangjunchen on 16/9/1.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+JTLoadingView.h"

@interface RCTLoadingView : UIView
@property (nonatomic, assign) BOOL animate;
@property (nonatomic, assign) ActivityIndicatorType animationType;
@end
