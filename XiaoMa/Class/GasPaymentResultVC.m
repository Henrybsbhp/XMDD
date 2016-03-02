//
//  GasPaymentResultVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/19.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasPaymentResultVC.h"
#import "NSString+RectSize.h"
#import "NSString+Split.h"
#import "SocialShareViewController.h"
#import "GetShareButtonOp.h"
#import "ShareResponeManager.h"

@interface GasPaymentResultVC ()
@end

@implementation GasPaymentResultVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"GasPaymentResultVC dealloc ~");
}
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
    [MobClick event:@"rp506_1"];
    GetShareButtonOp * op = [GetShareButtonOp operation];
    op.pagePosition = ShareSceneGas;
    [[op rac_postRequest] subscribeNext:^(GetShareButtonOp * op) {
        
        SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
        vc.sceneType = ShareSceneGas;    //页面位置
        NSString * paidStr = [NSString stringWithFormat:@"%ld", (long)self.chargeMoney];
        NSString * chargeStr = [NSString stringWithFormat:@"%@", [NSString formatForPrice:self.couponMoney]];
        NSMutableDictionary * otherDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:paidStr, @"gasCharge", chargeStr, @"spareCharge", nil];
        vc.otherInfo = otherDic;
        vc.btnTypeArr = op.rsp_shareBtns; //分享渠道数组
        
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
        sheet.shouldCenterVertically = YES;
        [sheet presentAnimated:YES completionHandler:nil];
        
        [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [MobClick event:@"rp110_7"];
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        [vc setClickAction:^{
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        
        [[ShareResponeManager init] setFinishAction:^(NSInteger code, ShareResponseType type){
            
        }];
        [[ShareResponeManagerForQQ init] setFinishAction:^(NSString * code, ShareResponseType type){
            
        }];
    } error:^(NSError *error) {
        [gToast showError:@"分享信息拉取失败，请重试"];
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
    if (self.dismissBlock) {
        self.dismissBlock(self.drawingStatus);
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

    cardnoL.text = [self.gasCard.gascardno splitByStep:4 replacement:@" "];
    leftpriceL.text = [NSString stringWithFormat:@"￥%ld", (long)self.chargeMoney];
    rightpriceL.text = [NSString stringWithFormat:@"￥%@", [NSString formatForPrice:self.paidMoney]];
    
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
