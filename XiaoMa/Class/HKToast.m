//
//  HKToast.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKToast.h"
#import "SVProgressHUD.h"
#import "MBProgressHUD.h"
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

- (void)showingWithoutText
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
}

- (void)showingWithText:(NSString *)test
{
    [SVProgressHUD showWithStatus:test maskType:SVProgressHUDMaskTypeClear];
}

- (void)showSuccess:(NSString *)success
{
    [SVProgressHUD showSuccessWithStatus:success];
}

- (void)showError:(NSString *)error
{
    if (error.length == 0) {
        [self dismiss];
    }
    else {
        [self showText:error];
        //        [SVProgressHUD showErrorWithStatus:error];
    }
}

- (void)showMistake:(NSString *)mistake
{
    if (mistake.length == 0) {
        [self dismiss];
    }
    else {
        //        [self showText:error];
        [SVProgressHUD showErrorWithStatus:mistake];
    }
}

- (void)showError:(NSString *)error inView:(UIView *)view
{
    [self showText:error inView:view];
}

- (void)showText:(NSString *)text
{
    [SVProgressHUD showOnlyStatus:text duration:[self displayDurationForString:text]];
}

- (void)showText:(NSString *)text inView:(UIView *)view
{
    if (text.length == 0) {
        [self dismissInView:view];
    }
    else {
        MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
        if (!hud) {
            hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        }
        hud.labelText = text;
        hud.margin = 10;
        hud.mode = MBProgressHUDModeText;
        [hud hide:YES afterDelay:[self displayDurationForString:text]];
    }
}

- (void)showingWithText:(NSString *)text inView:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = text;
}

- (void)dismissInView:(UIView *)view
{
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
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
    return MAX(1.8, MIN((float)string.length*0.1 + 0.3, 5.0));
}


@end
