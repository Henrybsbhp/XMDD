//
//  InviteCompleteVC.m
//  XiaoMa
//
//  Created by jt on 16/3/21.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "InviteCompleteVC.h"
#import "NSString+RectSize.h"
#import "CKLine.h"

#define kContentViewWidth   286
#define TopSpace 20
#define ItemSpace 6
#define HalfContentWidth 190
#define ContentWidth 256

@implementation InviteCompleteVC

- (void)dealloc
{
    DebugLog(@"InviteCompleteVC dealloc");
}

- (void)showWithActionHandler:(void (^)(NSInteger, id))handler
{
    CGFloat height = 0.0f;
    
    UIView * contentV = [[UIView alloc] initWithFrame:CGRectZero];
    
    UILabel * titleLb= [[UILabel alloc] init];
    titleLb.font = [UIFont systemFontOfSize:17];
    titleLb.textColor = kGrayTextColor;
    NSString * labelText = @"本团信息";
    titleLb.text = labelText;
    
    [contentV addSubview:titleLb];
    
    [titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(contentV);
        make.top.equalTo(contentV).offset(13);
    }];
    
    UIButton * closeBtn = [[UIButton alloc] init];
    [closeBtn setImage:[UIImage imageNamed:@"cancel_social"] forState:UIControlStateNormal];
    [contentV addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.width.height.mas_equalTo(23);
        make.right.equalTo(contentV).offset(-6);
        make.centerY.equalTo(titleLb);
    }];
    [[closeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        if (self.closeAction){
            
            self.closeAction();
        }
    }];
    
    
    CKLine * line = [[CKLine alloc] init];
    [contentV addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(contentV).offset(45);
        make.left.right.equalTo(contentV);
        make.height.mas_equalTo(1);
    }];
    
    height = 45.0;
    
    height += TopSpace;
    for (NSDictionary * dict in self.datasource)
    {
        NSString * title = dict[@"title"];
        NSString * content = dict[@"content"];
        NSString * color = dict[@"color"];
        
        CGSize size = [content labelSizeWithWidth:HalfContentWidth font:[UIFont systemFontOfSize:14]];
        
        UILabel * titleLb = [[UILabel alloc] init];
        titleLb.font = [UIFont systemFontOfSize:14];
        titleLb.textColor = kGrayTextColor;
        titleLb.text = title;
        [contentV addSubview:titleLb];
        [titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.leading.equalTo(contentV).offset(15);
            make.top.equalTo(contentV).offset(height);
        }];
        
        UILabel * contentLb = [[UILabel alloc] init];
        contentLb.font = [UIFont systemFontOfSize:14];
        contentLb.textColor = color.length ? HEXCOLOR(color) : kGrayTextColor;
        contentLb.text = content;
        [contentV addSubview:contentLb];
        
        [contentLb mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.trailing.equalTo(contentV).offset(-15);
            make.top.equalTo(contentV).offset(height);
        }];
        
        height = height + size.height + ItemSpace;
    }
    
    for (NSString * item in self.datasource2)
    {
        CGSize size = [item labelSizeWithWidth:ContentWidth font:[UIFont systemFontOfSize:14]];
        UILabel * contentLb = [[UILabel alloc] init];
        contentLb.font = [UIFont systemFontOfSize:14];
        contentLb.textColor = kGrayTextColor;
        contentLb.text = item;
        contentLb.numberOfLines = 0;
        [contentV addSubview:contentLb];
        
        [contentLb mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.leading.equalTo(contentV).offset(15);
            make.width.mas_equalTo(ContentWidth);
            make.top.equalTo(contentV).offset(height);
        }];
        
        height = height + size.height + ItemSpace;
    }
    height += 14;
    
    contentV.frame = CGRectMake(0, 0, kContentViewWidth, height);
    
    self.contentView = contentV;
    [super showWithActionHandler:handler];
}


@end
