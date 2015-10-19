//
//  GasPayForCZBVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/19.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasPayForCZBVC.h"
#import "NSString+RectSize.h"
#import "CKLimitTextField.h"

@interface GasPayForCZBVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation GasPayForCZBVC

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        CGSize lbsize = [[self paymentTitle] labelSizeWithWidth:tableView.frame.size.width-28 font:[UIFont systemFontOfSize:13]];
        return lbsize.height + 13;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 12;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [self titleCellAtIndexPath:indexPath];
    }
    else if (indexPath.section == 1) {
        cell = [self vcodeCellAtIndexPath:indexPath];
    }
    else if (indexPath.section == 2) {
        cell = [self orderCellAtIndexPath:indexPath];
    }
    return cell;
}

- (UITableViewCell *)titleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TitleCell"];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    NSString *tialno = [self.bankCard.cardNumber substringFromIndex:self.bankCard.cardNumber.length-4 length:4];
    titleL.text = [NSString stringWithFormat:@"您正在用浙商银行汽车卡尾号为%@的卡号充值油卡，点击“获取验证码”，验证码将发至年的银行预留手机号中，请及时输入验证码进行支付。", tialno];
    return cell;
}

- (UITableViewCell *)vcodeCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"VCodeCell" forIndexPath:indexPath];
    CKLimitTextField *field = (CKLimitTextField *)[cell.contentView viewWithTag:1001];
    UIButton *vcodeBtn = (UIButton *)[cell.contentView viewWithTag:1002];
    
    field.textLimit = 6;
    [[field rac_newTextChannel] subscribeNext:^(NSString *text) {
        vcodeBtn.enabled = text.length < 6 ? NO : YES;
    }];
    
    return cell;
}

- (UITableViewCell *)orderCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"OrderCell" forIndexPath:indexPath];
    return cell;
}

- (NSString *)paymentTitle
{
    NSString *tialno = [self.bankCard.cardNumber substringFromIndex:self.bankCard.cardNumber.length-4 length:4];
    return [NSString stringWithFormat:@"您正在用浙商银行汽车卡尾号为%@的卡号充值油卡，点击“获取验证码”，验证码将发至年的银行预留手机号中，请及时输入验证码进行支付。", tialno];
}

@end

