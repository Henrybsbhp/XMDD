//
//  UIView+Promption.h
//  HappyTrain
//
//  Created by jt on 14-11-26.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PromptionView.h"

@interface UIView (Promption)

@property (nonatomic,strong)PromptionView * promptionView;


- (void)showErrorInfo:(NSString * )info andClickOp:(void (^)(void))completion;

- (void)showLoadingInfo:(NSString * )info;

- (void)removePromptionView;

- (void)refreshPromptionView;

@end
