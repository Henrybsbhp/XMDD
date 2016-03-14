//
//  HKAlertVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKAlertVC.h"
#import "CKLine.h"
#import <MZFormSheetController.h>

#define kBottomViewHeight       49
#define kBottomViewLinePadding  5

@interface HKAlertVC ()

@end

@implementation HKAlertVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showWithActionHandler:(void(^)(NSInteger index, HKAlertVC *alert))handler
{
    CGRect frame = self.contentView.bounds;
    
    self.actionHandler = handler;
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.view addSubview:self.contentView];
    
    if (self.actionTitles.count > 0) {
        frame.size.height = frame.size.height + kBottomViewHeight;
        [self.view addSubview:[self bottomViewWithBounds:frame]];
    }
    self.view.frame = frame;
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:frame.size viewController:self];
    sheet.cornerRadius = 3;
    sheet.shadowRadius = 0;
    sheet.shadowOpacity = 0;
    sheet.transitionStyle = MZFormSheetTransitionStyleDropDown;
    sheet.shouldDismissOnBackgroundViewTap = NO;
    sheet.shouldCenterVertically = YES;
    [MZFormSheetController sharedBackgroundWindow].backgroundBlurEffect = NO;
    [sheet presentAnimated:YES completionHandler:nil];
}

- (UIView *)bottomViewWithBounds:(CGRect)bounds
{
    if (self.actionTitles.count == 0) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, bounds.size.height-kBottomViewHeight, bounds.size.width, kBottomViewHeight)];
    CGRect rect = CGRectMake(0, 0, floor(bounds.size.width/self.actionTitles.count), kBottomViewHeight);
    
    for (NSInteger i=0; i<self.actionTitles.count; i++) {
        NSString *title = self.actionTitles[i];
        rect.origin.x = i * rect.size.width;
        UIButton *btn = [[UIButton alloc] initWithFrame:rect];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:HEXCOLOR(@"#18d06a") forState:UIControlStateNormal];
        btn.tag = i;
        [btn addTarget:self action:@selector(actionClick:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
        
        if (i > 0) {
            CKLine *line = [[CKLine alloc] initWithFrame:CGRectMake(rect.origin.x, kBottomViewLinePadding,
                                                                    1, kBottomViewHeight-2*kBottomViewLinePadding)];
            line.lineAlignment = CKLineAlignmentVerticalLeft;
            line.lineColor = HEXCOLOR(@"#dedfe0");
            [view addSubview:view];
        }
    }
    CKLine *line = [[CKLine alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 1)];
    line.lineAlignment = CKLineAlignmentHorizontalTop;
    line.lineColor = HEXCOLOR(@"#dedfe0");
    [view addSubview:line];
    
    return view;
}

- (void)dismiss
{
    [self.formSheetController dismissAnimated:YES completionHandler:nil];
}

#pragma mark - Action
- (void)actionClick:(UIButton *)sender
{
    if (self.actionHandler) {
        self.actionHandler(sender.tag, self);
    }
}

@end
