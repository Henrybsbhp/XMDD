//
//  GasPaymentResultVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/19.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasPaymentResultVC.h"
#import "NSString+RectSize.h"
#import "SocialShareViewController.h"

@interface GasPaymentResultVC ()
@end

@implementation GasPaymentResultVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.detailText) {
        self.detailText = @"您充值的金额将在1个工作日内到账，到帐后请及时前往加油站圈存。如需开发票，请在圈存时向加油站工作人员索取。";
    }
}

#pragma mark - Action
- (IBAction)actionShare:(id)sender
{
    SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
    vc.tt = @"我在小马达达上购买了车险，赚大发了！";
    vc.subtitle = @"终于等到这一天，好运来到我身边，小马达达车险大“放”假期！嘘，一般人我不告诉他！";
    vc.image = [UIImage imageNamed:@"wechat_share_ins"];
    vc.webimage = [UIImage imageNamed:@"weibo_share_ins"];
    vc.urlStr = @"www.xiaomadada.com";
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
    sheet.shouldCenterVertically = YES;
    [sheet presentAnimated:YES completionHandler:nil];
    
    [vc setFinishAction:^{
        [sheet dismissAnimated:YES completionHandler:nil];
    }];
    
    [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [sheet dismissAnimated:YES completionHandler:nil];
    }];
}

- (void)actionBack:(id)sender
{
    if (self.originVC) {
        [self.navigationController popToViewController:self.originVC animated:YES];
    }
    else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - UITableViewDelegate And Datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        CGFloat ftsize = self.drawingStatus == DrawingBoardViewStatusSuccess ? 13 : 14;
        CGSize lbsize = [self.detailText labelSizeWithWidth:tableView.frame.size.width - 60 font:[UIFont systemFontOfSize:ftsize]];
        return lbsize.height + 31;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.drawingStatus == DrawingBoardViewStatusSuccess) {
        return 4;
    }
    return 3;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self setupHeaderCell:cell];
    }
    else if (indexPath.row == 1) {
        [self setupPaymentInfoCell:cell];
    }
    else if (indexPath.row == 2) {
        [self setupDetailTextCell:cell];
    }
}

- (void)setupHeaderCell:(UITableViewCell *)cell
{
    DrawingBoardView *drawingV = (DrawingBoardView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    if (drawingV.drawingStatus != self.drawingStatus) {
        [drawingV drawWithStatus:self.drawingStatus];
        titleL.text = self.drawingStatus == DrawingBoardViewStatusSuccess ? @"支付成功！" : @"支付失败！";
        titleL.textColor = self.drawingStatus == DrawingBoardViewStatusSuccess ? HEXCOLOR(@"#22ab22") : HEXCOLOR(@"#de1322");
    }
}

- (void)setupPaymentInfoCell:(UITableViewCell *)cell
{
    UIImageView *iconV = (UIImageView *)[cell viewWithTag:1001];
    UILabel *cardnoL = (UILabel *)[cell viewWithTag:1003];
    UILabel *leftpriceL = (UILabel *)[cell viewWithTag:1005];
    UILabel *rightpriceL = (UILabel *)[cell viewWithTag:1007];

    cardnoL.text = self.gasCard.gascardno;
    leftpriceL.text = [NSString stringWithFormat:@"￥%.2f", (float)self.gasPayOp.req_amount];
    rightpriceL.text = [NSString stringWithFormat:@"￥%.2f", (float)self.gasPayOp.rsp_total];
    
    BOOL highlighted = self.drawingStatus != DrawingBoardViewStatusSuccess;
    NSString *iconname = self.gasCard.cardtype == 1 ? @"gas_icon_snpn" : @"gas_icon_cnpc";
    iconV.image = [UIImage imageNamed:highlighted ? [NSString stringWithFormat:@"%@2", iconname] : iconname];
    for (NSInteger tag = 1002; tag < 1008; tag++) {
        UILabel *label = (UILabel *)[cell viewWithTag:tag];
        label.highlighted = highlighted;
    }
}

- (void)setupDetailTextCell:(UITableViewCell *)cell
{
    UILabel *textL = (UILabel *)[cell.contentView viewWithTag:1001];
    CGFloat ftsize = self.drawingStatus == DrawingBoardViewStatusSuccess ? 13 : 14;
    textL.font = [UIFont systemFontOfSize:ftsize];
    textL.text = self.detailText;
}

@end
