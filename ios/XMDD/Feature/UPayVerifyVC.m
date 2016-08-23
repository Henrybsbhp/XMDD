//
//  UPayVerifyVC.m
//  XMDD
//
//  Created by RockyYe on 16/8/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKSMSModel.h"
#import "UPayVerifyVC.h"
#import "DetailWebVC.h"
#import "PayInfoModel.h"
#import "UIView+Shake.h"
#import "AddBankCardVC.h"
#import "CheckoutUnioncardQuickpayOp.h"
#import "GetTokenOp.h"

@interface UPayVerifyVC ()<UITableViewDelegate, UITableViewDataSource>

/// 记录插入和删除的索引
@property (strong, nonatomic) NSArray *indexArr;
/// 是否打开选择其它银行卡
@property (assign, nonatomic) BOOL openMore;
@property (strong, nonatomic) HKSMSModel *smsModel;
@property (strong, nonatomic) CKList *dataSource;
@property (strong, nonatomic) NSString *vcode;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation UPayVerifyVC

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    DebugLog(@"UPayVerifyVC dealloc");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupDataSource];
    
}

#pragma mark - Setup

- (void)setupDataSource
{
    self.dataSource = $(
                        $(
                          [self headerCellDataForID:@"FeeCell"],
                          [self headerCellDataForID:@"ItemCell"]
                          ),
                        $(
                          [self cardCellData],
                          CKJoin([self createCardCellDataList]),
                          [self phoneNumCellData],
                          [self qrCodeCellData]
                          ),
                        $(
                          [self addCardCellData]
                          ),
                        $(
                          [self confirmCellData]
                          )
                        );
}

#pragma mark - Network

-(void)checkoutUnioncardQuickpay
{
    @weakify(self)
    
    CheckoutUnioncardQuickpayOp *op = [CheckoutUnioncardQuickpayOp operation];
    
    UnionBankCard *model = self.bankCardInfo.firstObject;
    op.req_tradeno = self.tradeNo;
    op.req_tokenid = model.tokenid;
    op.req_vcode = self.vcode;
    
    [[[op rac_postRequest]initially:^{
        
        [gToast showingWithText:@"银联快捷支付中"];
        
    }]subscribeNext:^(CheckoutUnioncardQuickpayOp *op) {
        
        @strongify(self)
        
        [gToast showSuccess:@"银联快捷支付成功"];
        
        [self.subject sendNext:op];
        [self.subject sendCompleted];
        [self actionDismiss:nil];
        
    } error:^(NSError *error) {
        
        [gToast showMistake:@"银联快捷支付失败"];
        
    }];
    
}

#pragma mark - Cell

- (CKDict *)headerCellDataForID:(NSString *)identifier
{
    
    @weakify(self)
    
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"HeaderCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 40;
    });
    
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self)
        
        UILabel *titleLabel = [cell viewWithTag:100];
        UILabel *detailLabel = [cell viewWithTag:101];
        
        if ([identifier isEqualToString:@"FeeCell"])
        {
            titleLabel.text = @"订单金额";
            detailLabel.text = [NSString stringWithFormat:@"¥%.2f",self.orderFee];
            detailLabel.textColor = HEXCOLOR(@"#FF7428");
        }
        else
        {
            titleLabel.text = @"服务项目";
            detailLabel.text = self.serviceName;
            detailLabel.textColor = HEXCOLOR(@"#454545");
        }
        
    });
    
    return data;
    
}

- (CKDict *)cardCellData
{
    
    @weakify(self)
    
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"CardCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 48;
    });
    
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self)
        
        UnionBankCard *model = self.bankCardInfo.firstObject;
        
        UILabel *bankLabel = [cell viewWithTag:101];
        bankLabel.text = model.issuebank.length == 0 ? @" " : model.issuebank;
        
        UILabel *detailLabel = [cell viewWithTag:102];
        detailLabel.text = [NSString stringWithFormat:@"尾号%@（%@）",model.cardno, model.cardtypename];
        
        UIImageView *imgView = [cell viewWithTag:103];
        
        [[RACObserve(self.smsModel.getVcodeButton, enabled)takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
            
            if (self.bankCardInfo.count > 1 && self.smsModel.getVcodeButton.enabled)
            {
                imgView.hidden = NO;
                
                NSLayoutConstraint *constraint = [self findConstraintInConstraintArr:cell.contentView.constraints];
                constraint.constant = 40;
            }
            else
            {
                imgView.hidden = YES;
                
                NSLayoutConstraint *constraint = [self findConstraintInConstraintArr:cell.contentView.constraints];
                constraint.constant = 15;
            }
            
        }];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            @strongify(self)
            
            imgView.image = self.openMore ? [UIImage imageNamed:@"arrow_up"] : [UIImage imageNamed:@"arrow_down"];
            
        }];
        
    });
    
    data[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self)
        
        if (self.bankCardInfo.count > 1 && self.smsModel.getVcodeButton.enabled)
        {
            [self folderTableView];
        }
        
    });
    
    return data;
    
}

- (CKDict *)otherCardCellDataWithModel:(UnionBankCard *)model
{
    
    @weakify(self)
    
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"OtherCardCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 48;
    });
    
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self)
        
        UnionBankCard *model = [self.bankCardInfo safetyObjectAtIndex:indexPath.row];
        
        UILabel *bankLabel = [cell viewWithTag:101];
        bankLabel.text = model.issuebank;
        
        UILabel *detailLabel = [cell viewWithTag:102];
        detailLabel.text = [NSString stringWithFormat:@"尾号%@（%@）",model.cardno, model.cardtypename];
        
    });
    
    data[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self)
        
        // 如果出现可选择其它银行卡，indexPath.row一定不会越界
        // 移动银行卡位置
        NSMutableArray *temp = [self.bankCardInfo mutableCopy];
        [temp exchangeObjectAtIndex:0 withObjectAtIndex:(indexPath.row)];
        self.bankCardInfo = [temp copy];
        [self folderTableView];
        
    });
    
    return data;
    
}


- (CKDict *)phoneNumCellData
{
    
    @weakify(self)
    
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"PhoneNumCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 48;
    });
    
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self)
        
        UnionBankCard *bankCard = self.bankCardInfo.firstObject;
        
        UIButton *button = [cell viewWithTag:101];
        button.hidden = bankCard.changephoneurl.length == 0;
        [[[button rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
            vc.url = [NSString stringWithFormat:@"%@/%@",bankCard.changephoneurl,self.tradeNo];
            [self.navigationController pushViewController:vc animated:YES];
        }];
        
        UnionBankCard *model = self.bankCardInfo.firstObject;
        
        UILabel *phoneLabel = [cell viewWithTag:102];
        phoneLabel.text = model.bindphone;
        
    });
    
    return data;
    
}

/// 获取验证码cell
- (CKDict *)qrCodeCellData
{
    
    @weakify(self)
    
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"QRCodeCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 48;
    });
    
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self)
        
        VCodeInputField *textField = [cell viewWithTag:101];
        textField.keyboardType = UIKeyboardTypeNumberPad;
        self.smsModel.inputVcodeField = textField;
        
        [[textField.rac_textSignal takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
            
            @strongify(self)
            
            self.vcode = x;
            
        }];
        
        UIButton *button = [cell viewWithTag:102];
        [button setTitleColor:kDefTintColor forState:UIControlStateNormal];
        [button setTitleColor:HEXCOLOR(@"#CFDBD3") forState:UIControlStateDisabled];
        
        self.smsModel.getVcodeButton = button;
        [[[button rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
            
            @strongify(self)
            
            if (self.openMore)
            {
                [self folderTableView];
            }
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            
            NSLayoutConstraint *constraint = [self findConstraintInConstraintArr:cell.constraints];
            constraint.constant = 15;
            
            UIImageView *imgView = [cell viewWithTag:103];
            imgView.hidden = YES;
            
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
            
            UnionBankCard *bankCard = self.bankCardInfo.firstObject;
            [self getUnionSmsWithTokenID:bankCard.tokenid];
            [textField becomeFirstResponder];

            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
            
        }];
        
    });
    
    return data;
    
}

- (CKDict *)addCardCellData
{
    @weakify(self)
    
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"AddCardCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 50;
    });
    
    data[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self)
        
        AddBankCardVC *vc = [UIStoryboard vcWithId:@"AddBankCardVC" inStoryboard:@"Bank"];
        vc.tradeNum = self.tradeNo;
        vc.subject = self.subject;
        [self.navigationController pushViewController:vc animated:YES];
        
    });
    return data;
    
}

- (CKDict *)confirmCellData
{
    
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"ConfirmCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 70;
    });
    
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UIButton *button = [cell viewWithTag:100];
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        
        [[[button rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
            
            if (self.vcode.length == 0)
            {
                [gToast showMistake:@"请填写验证码"];
            }
            else
            {
                
                [self.view endEditing:YES];
                [self checkoutUnioncardQuickpay];
            }
            
        }];
        
    });
    
    return data;
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(CKList *)self.dataSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item[kCKCellID] forIndexPath:indexPath];
    CKCellPrepareBlock block = item[kCKCellPrepare];
    if (block) {
        block(item, cell, indexPath);
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    CKCellGetHeightBlock block = item[kCKCellGetHeight];
    if (block)
    {
        return block(item, indexPath);
    }
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    if (item[kCKCellSelected])
    {
        CKCellSelectedBlock block = item[kCKCellSelected];
        block(item, indexPath);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return CGFLOAT_MIN;
    }
    else
    {
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

#pragma mark - Action

- (IBAction)actionDismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Utility

-(NSLayoutConstraint *)findConstraintInConstraintArr:(NSArray *)constraints
{
    for (NSLayoutConstraint *constraint in constraints)
    {
        if ([constraint.identifier isEqualToString:@"carNoTrailing"])
        {
            return constraint;
        }
    }
    return nil;
}

- (void)shakeVCodeTextField
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]];
    [cell.contentView shake];
}

-(void)folderTableView
{
    self.openMore = !self.openMore;
    
    [self setupDataSource];
    
    [self.tableView beginUpdates];
    
    if (self.openMore)
    {
        [self.tableView insertRowsAtIndexPaths:[self createIndexArr] withRowAnimation:UITableViewRowAnimationMiddle];
    }
    else
    {
        
        [self.tableView deleteRowsAtIndexPaths:[self createIndexArr] withRowAnimation:UITableViewRowAnimationMiddle];
    }
    
    [self.tableView endUpdates];
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1],[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    
}

- (NSArray *)createCardCellDataList
{
    if (self.openMore)
    {
        NSMutableArray *otherCellDataArr = [[NSMutableArray alloc]init];
        
        for (NSInteger i = 1; i < self.bankCardInfo.count; i++)
        {
            CKDict *data = [self otherCardCellDataWithModel:[self.bankCardInfo safetyObjectAtIndex:i]];
            [otherCellDataArr addObject:data];
        }
        
        return [NSArray arrayWithArray:otherCellDataArr];
    }
    else
    {
        return nil;
    }
}

- (NSArray *)createIndexArr
{
    NSMutableArray *indexArr = [[NSMutableArray alloc]init];
    
    for (NSInteger i = 1; i < self.bankCardInfo.count; i++)
    {
        [indexArr addObject:[NSIndexPath indexPathForRow:i inSection:1]];
    }
    
    return [NSArray arrayWithArray:indexArr];
}

/// 获取验证码
- (void)getUnionSmsWithTokenID:(NSString *)tokenID
{
    // 测试
    RACSignal *sig = [self.smsModel rac_getUnionCardVcodeWithTokenID:tokenID andTradeNo:self.tradeNo];
    // 60s等待时间
    [[self.smsModel rac_startGetLongIntervalVcodeWithFetchVcodeSignal:sig andPhone:gAppMgr.myUser.userID]subscribeError:^(NSError *error) {
        
        [gToast showError:error.domain];
        
    } completed:^{
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        
        NSLayoutConstraint *constraint = [self findConstraintInConstraintArr:cell.constraints];
        constraint.constant = 40;
        
        UIImageView *imgView = [cell viewWithTag:103];
        imgView.hidden = NO;
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    }];
}


#pragma mark - LazyLoad

-(RACSubject *)subject
{
    if (!_subject)
    {
        _subject = [RACSubject subject];
    }
    return _subject;
}

- (CKList *)dataSource
{
    if (!_dataSource)
    {
        _dataSource = [CKList list];
    }
    return _dataSource;
}

-(HKSMSModel *)smsModel
{
    if (!_smsModel)
    {
        _smsModel = [[HKSMSModel alloc] init];
        [_smsModel setupWithTargetVC:self mobEvents:nil];
        [_smsModel countDownIfNeededWithVcodeType:HKVcodeTypeLogin];
    }
    return _smsModel;
}



@end
