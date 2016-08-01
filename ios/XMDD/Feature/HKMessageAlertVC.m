//
//  HKMessageAlertVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/25.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKMessageAlertVC.h"
#import "NSString+RectSize.h"

#define kAlertViewWidth     280

@interface HKMessageAlertVC ()

@end

@implementation HKMessageAlertVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contentInsets = UIEdgeInsetsMake(30, 25, 30, 25);
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.messageLabel.font = [UIFont systemFontOfSize:14];
        self.messageLabel.textColor = kGrayTextColor;
        self.messageLabel.numberOfLines = 0;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        self.titleLabel.textColor = kDarkTextColor;
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        self.minMessageContentViewHeight = 135;
        self.verticalSpace = 20;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showWithActionHandler:(void(^)(NSInteger index, id alertVC))actionHandler {
    CGFloat contentHeight = [self getContentViewHeight];
    self.contentView = [self createContentViewWithFrame:CGRectMake(0, 0, kAlertViewWidth, contentHeight)];
    [super showWithActionHandler:actionHandler];
}

- (UIView *)createContentViewWithFrame:(CGRect)frame {
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    [contentView addSubview:[self getAndSetupSizeForMessageLabelWithContainerBounds:frame]];
    [contentView addSubview:[self getAndSetupSizeForTitleLabelWithContainerBounds:frame]];
    return contentView;
}

- (CGFloat)getContentViewHeight {
    CGFloat titleHeight = [self getTitleLabelSize].height;
    CGFloat msgHeight = [self getMessageLabelSize].height;
    CGFloat contentHeight = self.contentInsets.top + titleHeight + (titleHeight ? self.verticalSpace : 0) + msgHeight + self.contentInsets.bottom;
    return MAX(self.minMessageContentViewHeight, contentHeight);
}

- (UILabel *)getAndSetupSizeForTitleLabelWithContainerBounds:(CGRect)bounds {
    CGSize titleSize = [self getTitleLabelSize];
    CGFloat y = self.contentInsets.top;
    self.titleLabel.frame = CGRectMake(self.contentInsets.left, y, kAlertViewWidth - self.contentInsets.left - self.contentInsets.right,titleSize.height );
    return self.titleLabel;
}

- (UILabel *)getAndSetupSizeForMessageLabelWithContainerBounds:(CGRect)bounds {
    CGSize titleSize = [self getTitleLabelSize];
    CGSize msgSize = [self getMessageLabelSize];
    CGFloat boundsHeight = bounds.size.height - self.contentInsets.top - self.contentInsets.bottom - titleSize.height - (titleSize.height > 0 ? self.verticalSpace : 0);
    CGFloat y = self.contentInsets.top + titleSize.height + (titleSize.height > 0 ? self.verticalSpace : 0);
    if (boundsHeight > msgSize.height) {
        y = y + floor((boundsHeight - msgSize.height)/2);
    }
    self.messageLabel.frame = CGRectMake(self.contentInsets.left, y, msgSize.width, msgSize.height);
    return self.messageLabel;
}

- (CGSize)getMessageLabelSize {
    CGFloat labelWidth = kAlertViewWidth - self.contentInsets.left - self.contentInsets.right;
    CGSize labelSize = [self.messageLabel.text labelSizeWithWidth:labelWidth font:self.messageLabel.font];
    return CGSizeMake(labelSize.width, ceil(labelSize.height));
}

- (CGSize)getTitleLabelSize {
    CGFloat labelWidth = kAlertViewWidth - self.contentInsets.left - self.contentInsets.right;
    CGSize labelSize = [self.titleLabel.text labelSizeWithWidth:labelWidth font:self.titleLabel.font];
    return CGSizeMake(labelSize.width, ceil(labelSize.height));
}

@end
