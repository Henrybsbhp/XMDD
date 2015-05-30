//
//  HKToast.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKToast.h"
#import "SVProgressHUD.h"
#import "XiaoMa.h"

@interface HKToast ()
@property (nonatomic, strong) UIView *targetView;
@end
@implementation HKToast

+ (instancetype)sharedTosast
{
    static HKToast *g_toast;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_toast = [[HKToast alloc] init];
    });
    return g_toast;
}

- (void)showingWithText:(NSString *)test
{
    [SVProgressHUD showWithStatus:test maskType:SVProgressHUDMaskTypeNone];
}

- (void)showSuccess:(NSString *)success
{
    [SVProgressHUD showSuccessWithStatus:success];
}

- (void)showError:(NSString *)error
{
    [SVProgressHUD showErrorWithStatus:error];
}

- (void)showText:(NSString *)text
{
    [SVProgressHUD showOnlyStatus:text duration:[self displayDurationForString:text]];
}

- (void)dismiss
{
    [SVProgressHUD dismiss];
}

#pragma mark - Utility
- (NSString *)hudKey
{
    return [NSString stringWithFormat:@"$ProgressHUD_%@", self];
}

- (NSTimeInterval)displayDurationForString:(NSString*)string
{
    return MIN((float)string.length*0.1 + 0.3, 5.0);
}


@end
