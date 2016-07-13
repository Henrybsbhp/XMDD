//
//  MutInsCalculateResultVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/7/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutInsCalculateResultVC.h"

@interface MutInsCalculateResultVC ()
@property (weak, nonatomic) IBOutlet UILabel *brandNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *frameNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *premiumPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *shareMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinBtn;

@end

@implementation MutInsCalculateResultVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Setup

-(void)setUI
{
    
    self.joinBtn.layer.cornerRadius = 5;
    self.joinBtn.layer.masksToBounds = YES;
    
    self.brandNameLabel.text = [NSString stringWithFormat:@"%@",self.model.brandName];
    self.frameNoLabel.text = [NSString stringWithFormat:@"%@",self.model.frameNo];
    self.premiumPriceLabel.text = [NSString stringWithFormat:@"%@",self.model.premiumPrice];
    self.serviceFeeLabel.text = [NSString stringWithFormat:@"%@",self.model.serviceFee];
    self.shareMoneyLabel.text = [NSString stringWithFormat:@"%@",self.model.shareMoney];
    
    NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc]initWithString:self.model.note];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:8];//调整行间距
    [noteStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [noteStr length])];
    self.noteLabel.attributedText = noteStr;
}

#pragma mark - Action

- (IBAction)actionJoin:(id)sender {
}

@end
