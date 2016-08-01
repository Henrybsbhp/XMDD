//
//  InviteAlertVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/16.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "InviteAlertVC.h"

#define kContentViewWidth   286

@interface InviteAlertVC ()

@end


@implementation InviteAlertVC

- (void)dealloc
{
    DebugLog(@"InviteAlertVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)showWithActionHandler:(void (^)(NSInteger, id))handler {
    
    UIView * contentV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kContentViewWidth, 133)];
    if (self.alertType == InviteAlertTypeNologin) {
        
        NSString * labelText = @"您还未登录小马达达，若想加入小马互助团，请先登录。是否现在登录";
        UILabel * wordLabel = [self creatLabelWithFrame:CGRectMake(17, 0, kContentViewWidth - 34, 133) andText:labelText];
        [contentV addSubview:wordLabel];
        self.contentView = contentV;
    }
    else if (self.alertType == InviteAlertTypeGotoWechat) {
        NSString * codeText = self.contentStr;
        UILabel * codeLabel = [self creatLabelWithFrame:CGRectMake(17, 0, kContentViewWidth - 34, 133) andText:codeText];
        codeLabel.numberOfLines = 5;
        codeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [contentV addSubview:codeLabel];
        self.contentView = contentV;
    }
    else if (self.alertType == InviteAlertTypeJoin) {
        
        NSString * labelText = self.groupType == 1 ? @"您已复制自组互助团口令，请确认是否要加入该互助团：" : @"您已复制平台互助团口令，请确认是否要加入该互助团：";
        UILabel * wordLabel = [self creatLabelWithFrame:CGRectMake(17, 15, kContentViewWidth - 34, 50) andText:labelText];
        [contentV addSubview:wordLabel];
        
        UILabel * groupL = [[UILabel alloc] initWithFrame:CGRectMake(17, 75, 60, 25)];
        groupL.font = [UIFont systemFontOfSize:14];
        groupL.textColor = kGrayTextColor;
        groupL.text = @"团队名称";
        [contentV addSubview:groupL];
        
        
        if (self.groupType == GroupTypeByself) {
            UILabel * leaderL = [[UILabel alloc] initWithFrame:CGRectMake(17, 100, 60, 25)];
            leaderL.font = [UIFont systemFontOfSize:14];
            leaderL.textColor = kGrayTextColor;
            leaderL.text = @"团长名称";
            [contentV addSubview:leaderL];
            
            UILabel * leaderNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 100, kContentViewWidth - 100, 25)];
            leaderNameLabel.font = [UIFont systemFontOfSize:14];
            leaderNameLabel.textColor = kDarkTextColor;
            leaderNameLabel.text = self.leaderName;
            leaderNameLabel.textAlignment = NSTextAlignmentRight;
            [contentV addSubview:leaderNameLabel];
        }
        
        UILabel * groupNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 75, kContentViewWidth - 100, 25)];
        groupNameLabel.font = [UIFont systemFontOfSize:14];
        groupNameLabel.textColor = kDarkTextColor;
        groupNameLabel.text = self.groupName;
        groupNameLabel.textAlignment = NSTextAlignmentRight;
        [contentV addSubview:groupNameLabel];
        
        self.contentView = contentV;
    }
    else if (self.alertType == InviteAlertTypeCopyCode) {
        
        NSString * labelText = @"暗号已复制到您的粘贴板，您可以长按粘贴给好友，或者直接在申请页面粘贴暗号选择其他车辆入团";
        UILabel * wordLabel = [self creatLabelWithFrame:CGRectMake(17, 0, kContentViewWidth - 34, 133) andText:labelText];
        [contentV addSubview:wordLabel];
        self.contentView = contentV;
    }
    else {
        return;
    }
    [super showWithActionHandler:handler];
}

- (UILabel *)creatLabelWithFrame:(CGRect)rect andText:(NSString *)text
{
    UILabel * label = [[UILabel alloc] initWithFrame:rect];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = kGrayTextColor;
    label.numberOfLines = 0;
    label.attributedText = [self setLineSpacing:text];
    return label;
}

- (NSAttributedString *)setLineSpacing:(NSString *)text
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:6]; //行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    return attributedString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
