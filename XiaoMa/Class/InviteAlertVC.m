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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)showWithActionHandler:(void (^)(NSInteger, HKAlertVC*))handler {
    if (self.alertType == InviteAlertTypeCopy) {
        UIView * contentV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kContentViewWidth, 133)];
        UILabel * wordLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, kContentViewWidth - 36, 133)];
        wordLabel.font = [UIFont systemFontOfSize:14];
        wordLabel.textColor = HEXCOLOR(@"#888888");
        wordLabel.numberOfLines = 0;
        NSString * labelText = @"这里是要被替换的口令：答复暗讽哈德福爱尚东风浩荡发源地是废话很舒服暗示发送到发斯蒂芬发";
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:6]; //行间距
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
        wordLabel.attributedText = attributedString;
        
        [contentV addSubview:wordLabel];
        self.contentView = contentV;
    }
    [super showWithActionHandler:handler];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
