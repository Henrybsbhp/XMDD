//
//  InsuranceResultVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/7/29.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceResultVC.h"

@interface InsuranceResultVC ()

@property (assign, nonatomic) InsuranceResult insuranceResultType;
@property (weak, nonatomic) IBOutlet UIView *drawView;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *failureContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
- (IBAction)shareAction:(id)sender;

@end

@implementation InsuranceResultVC

-(void)setResultType:(InsuranceResult) resultType
{
    self.insuranceResultType = resultType;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.insuranceResultType == OrderSuccess) {
        self.navigationItem.title = @"预约结果";
        self.resultLabel.text = @"恭喜，预约成功 ！";
        self.resultLabel.textColor = [UIColor colorWithHex:@"#fa8585" alpha:1.0f];
        NSString * content = @"工作人员将尽快联系您，为您办理相关保险事宜，请保持手机畅通，谢谢您的信任，请耐心等待！";
        self.failureContentLabel.attributedText = [self setLabelContent:content];
        self.shareButton.hidden = YES;
    }
    else if (self.insuranceResultType == PaySuccess) {
        self.resultLabel.text = @"恭喜，支付成功 ！";
        self.resultLabel.textColor = [UIColor colorWithHex:@"#2db637" alpha:1.0f];
        self.failureContentLabel.hidden = YES;
        self.shareButton.layer.masksToBounds = YES;
        self.shareButton.layer.cornerRadius = 11;
    }
    else {
        self.resultLabel.text = @"支付失败 ！";
        self.resultLabel.textColor = [UIColor colorWithHex:@"#e72c2c" alpha:1.0f];
        NSString * content = @"失败原因：请检查网络！";
        self.failureContentLabel.attributedText = [self setLabelContent:content];
        self.shareButton.hidden = YES;
    }
}

- (NSMutableAttributedString *) setLabelContent:(NSString *) contentStr
{
    //设置行间距、居中等
    NSMutableAttributedString * attributedStr = [[NSMutableAttributedString alloc] initWithString:contentStr];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8.0f;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [attributedStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, contentStr.length)];
    return attributedStr;
}

- (IBAction)shareAction:(id)sender {
    
}
@end
