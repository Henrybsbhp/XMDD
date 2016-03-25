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
        self.messageLabel.textColor = HEXCOLOR(@"#888888");
        self.messageLabel.numberOfLines = 0;
        self.minMessageContentViewHeight = 135;
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
    return contentView;
}

- (CGFloat)getContentViewHeight {
    CGFloat msgHeight = [self getMessageLabelSize].height;
    return MAX(self.minMessageContentViewHeight, msgHeight + self.contentInsets.top + self.contentInsets.bottom);
}

- (UILabel *)getAndSetupSizeForMessageLabelWithContainerBounds:(CGRect)bounds {
    CGSize msgSize = [self getMessageLabelSize];
    CGFloat y = self.contentInsets.top;
    if (bounds.size.height - self.contentInsets.top - self.contentInsets.bottom > msgSize.height) {
        y = floor((bounds.size.height - msgSize.height)/2);
    }
    self.messageLabel.frame = CGRectMake(self.contentInsets.left, y, msgSize.width, msgSize.height);
    return self.messageLabel;
}

- (CGSize)getMessageLabelSize {
    CGFloat labelWidth = kAlertViewWidth - self.contentInsets.left - self.contentInsets.right;
    CGSize labelSize = [self.messageLabel.text labelSizeWithWidth:labelWidth font:self.messageLabel.font];
    return CGSizeMake(labelSize.width, ceil(labelSize.height));
}

@end
