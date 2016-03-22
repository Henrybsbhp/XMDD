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
#define ContentWidth 260

@implementation InviteCompleteVC

- (void)showWithActionHandler:(void (^)(NSInteger, id))handler
{
    CGFloat height = 0.0f;
    
    UIView * contentV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kContentViewWidth, 133)];
    
    UILabel * titleLb= [[UILabel alloc] init];
    titleLb.font = [UIFont systemFontOfSize:17];
    titleLb.textColor = HEXCOLOR(@"#888888");
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
        make.top.equalTo(contentV).offset(6);
    }];
    
    
    CKLine * line = [[CKLine alloc] init];
    [contentV addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(contentV).offset(45);
        make.left.right.equalTo(contentV);
        make.height.mas_equalTo(1);
    }];
    
    height = 45.0;
    for (NSDictionary * dict in self.datasource)
    {
        NSString * title = dict[@"title"];
        NSString * content = dict[@"content"];
        
        [content labelSizeWithWidth:HalfContentWidth font:[UIFont systemFontOfSize:14]];
        
    }
    
}

- (void)caleContentViewHeight
{
    CGFloat topHeight = 46;
    CGFloat height = 0.0f;
    for (NSDictionary * dict in self.datasource)
    {
        NSString * title = dict[@"title"];
        NSString * content = dict[@"content"];
        
        [content labelSizeWithWidth:HalfContentWidth font:[UIFont systemFontOfSize:14]];
    }
}

@end
