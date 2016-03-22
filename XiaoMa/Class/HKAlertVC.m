//
//  HKAlertVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKAlertVC.h"
#import "CKLine.h"
#import <JCAlertView.h>

#define kBottomViewHeight       49
#define kBottomViewLinePadding  0

@interface HKAlertVC ()
@property (nonatomic, copy) void(^actionHandler)(NSInteger index, id alertView);
@property (nonatomic, weak) JCAlertView *alertView;
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

- (void)show
{
    [self showWithActionHandler:nil];
}

- (void)showWithActionHandler:(void(^)(NSInteger index, id alertVC))actionHandler
{
    _actionHandler = actionHandler;
    CGRect frame = self.contentView.bounds;
    
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.view addSubview:self.contentView];
    
    if (self.actionItems.count > 0) {
        frame.size.height = frame.size.height + kBottomViewHeight;
        [self.view addSubview:[self bottomViewWithBounds:frame]];
    }
    self.view.frame = frame;
    self.view.layer.cornerRadius = 3;
    self.view.layer.masksToBounds = YES;
    JCAlertView *alert = [[JCAlertView alloc] initWithCustomView:self.view dismissWhenTouchedBackground:NO];
    alert.customObject = self;
    self.alertView = alert;
    [alert show];
}

- (void)dismiss
{
    [self.alertView dismissWithCompletion:nil];
}

#pragma mark - Action
- (void)actionClick:(UIButton *)sender
{
    HKAlertActionItem *item = self.actionItems[sender.tag];
    if (item.clickBlock) {
        item.clickBlock(self);
    }
    if (self.actionHandler) {
        self.actionHandler(sender.tag, self);
    }
}

#pragma mark - Private
- (UIView *)bottomViewWithBounds:(CGRect)bounds
{
    if (self.actionItems.count == 0) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, bounds.size.height-kBottomViewHeight, bounds.size.width, kBottomViewHeight)];
    CGRect rect = CGRectMake(0, 0, floor(bounds.size.width/self.actionItems.count), kBottomViewHeight);
    
    for (NSInteger i=0; i<self.actionItems.count; i++) {
        HKAlertActionItem *item = self.actionItems[i];
        rect.origin.x = i * rect.size.width;
        UIButton *btn = [[UIButton alloc] initWithFrame:rect];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitle:item.title forState:UIControlStateNormal];
        [btn setTitleColor:item.color forState:UIControlStateNormal];
        btn.tag = i;
        [btn addTarget:self action:@selector(actionClick:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
        
        if (i > 0) {
            CKLine *line = [[CKLine alloc] initWithFrame:CGRectMake(rect.origin.x, kBottomViewLinePadding,
                                                                    1, kBottomViewHeight-2*kBottomViewLinePadding)];
            line.lineAlignment = CKLineAlignmentVerticalLeft;
            line.lineColor = HEXCOLOR(@"#dedfe0");
            [view addSubview:line];
        }
    }
    CKLine *line = [[CKLine alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 1)];
    line.lineAlignment = CKLineAlignmentHorizontalTop;
    line.lineColor = HEXCOLOR(@"#dedfe0");
    [view addSubview:line];
    
    return view;
}

@end

@implementation HKAlertActionItem

+ (instancetype)item {
    return [[self alloc] init];
}

+ (instancetype)itemWithTitle:(NSString *)title
{
    return [self itemWithTitle:title color:HEXCOLOR(@"#18d06a") clickBlock:nil];
}

+ (instancetype)itemWithTitle:(NSString *)title color:(UIColor *)color clickBlock:(void(^)(id alertVC))block {
    HKAlertActionItem *item = [[self alloc] init];
    item.title = title;
    item.color  =color;
    item.clickBlock = block;
    return item;
}


@end
