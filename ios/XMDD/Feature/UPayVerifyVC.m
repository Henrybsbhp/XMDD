//
//  UPayVerifyVC.m
//  XMDD
//
//  Created by RockyYe on 16/8/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKSMSModel.h"
#import "UPayVerifyVC.h"
#import "NetworkManager.h"

// 倒入头文件
@class MyBankCardListModel;

@interface UPayVerifyVC ()<UITableViewDelegate, UITableViewDataSource>


@property (strong, nonatomic) CKList *dataSource;
@property (strong, nonatomic) HKSMSModel *smsModel;
/// 是否打开选择其它银行卡
@property (assign, nonatomic) BOOL openMore;
// @YZC 可能需要更改
@property (strong, nonatomic) NSString *currentPhone;
@property (strong, nonatomic) NSMutableArray *cards;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation UPayVerifyVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupSimulateData];
    [self setupDataSource];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
    
}

#pragma mark - Setup

- (void)setupSimulateData
{
    self.orderFee = 100.00;
    self.serviceName = @"壳牌 蓝喜力矿物机油HX3 15W-40 SN级 4L";
}

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
                          self.openMore ? [self otherCardCellData] : CKNULL,
                          self.openMore ? [self otherCardCellData] : CKNULL,
                          self.openMore ? [self otherCardCellData] : CKNULL,
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



#pragma mark - Cell

- (CKDict *)headerCellDataForID:(NSString *)identifier
{
    
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"HeaderCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 40;
    });
    
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        
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
        
        MyBankCardListModel *model = self.cards.firstObject;
        
        UILabel *bankLabel = [cell viewWithTag:101];
        bankLabel.text = @"招商银行";
        
        UILabel *detailLabel = [cell viewWithTag:102];
        detailLabel.text = @"尾号5710(民生借记卡)";
        
        UIImageView *imgView = [cell viewWithTag:103];
        imgView.image = self.openMore ? [UIImage imageNamed:@"cw_arrow_down"] : [UIImage imageNamed:@"cw_arrow_down"];
        
    });
    
    data[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        UIImageView *imgView = [cell viewWithTag:103];
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            if (!self.openMore)
            {
                imgView.transform = CGAffineTransformMakeRotation(M_PI);
            }
            else
            {
                imgView.transform = CGAffineTransformMakeRotation(-M_PI);
            }
            
        } completion:nil];
        
        
        [self folderTableView];
        
    });
    
    return data;

}

- (CKDict *)otherCardCellData//WithModel:(MyBankCardListModel *)model
{
    
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"OtherCardCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 48;
    });
    
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UILabel *bankLabel = [cell viewWithTag:101];
        bankLabel.text = @"广发银行";
        
        UILabel *detailLabel = [cell viewWithTag:102];
        detailLabel.text = @"尾号6481(民生借记卡)";
        
    });
    
    data[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        [self.cards exchangeObjectAtIndex:0 withObjectAtIndex:(indexPath.row - 1)];
        [self folderTableView];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        
    });
    
    return data;
    
}


- (CKDict *)phoneNumCellData
{
    
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"PhoneNumCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 48;
    });
    
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UIButton *button = [cell viewWithTag:101];
        [[[button rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
        }];
        
        UILabel *phoneLabel = [cell viewWithTag:102];
        phoneLabel.text = @"188****8594";
        
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
        
        
        VCodeInputField *textField = [cell viewWithTag:101];
        self.smsModel.inputVcodeField = textField;
        [[[textField rac_signalForControlEvents:UIControlEventEditingDidBegin]takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
            
            
        }];
        
        UIButton *button = [cell viewWithTag:102];
        self.smsModel.getVcodeButton = button;
        [[[button rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
            
            @strongify(self)
            
            [self getUnionSms];
            
        }];
        
    });
    
    return data;
    
}

- (CKDict *)addCardCellData
{
    
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"AddCardCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 50;
    });
    
    data[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
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

#pragma mark - Utility

-(void)folderTableView
{
    self.openMore = !self.openMore;
    
    [self setupDataSource];
    
    [self.tableView beginUpdates];
    
    if (self.openMore)
    {
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1],
                                                 [NSIndexPath indexPathForRow:2 inSection:1],
                                                 [NSIndexPath indexPathForRow:3 inSection:1],]
                              withRowAnimation:UITableViewRowAnimationMiddle];
    }
    else
    {
        
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1],
                                                 [NSIndexPath indexPathForRow:2 inSection:1],
                                                 [NSIndexPath indexPathForRow:3 inSection:1],] withRowAnimation:UITableViewRowAnimationMiddle];
    }
    
    [self.tableView endUpdates];
}

- (NSArray *)createCardCellDataList
{
//    NSMutableArray *mArr = [[NSMutableArray alloc]init];
    return nil;
}

/// 获取验证码
- (void)getUnionSms
{
    RACSignal *sig = [self.smsModel rac_getUnionCardVcodeWithTokenID:[NetworkManager sharedManager].token andTradeNo:self.tradeNo];
    [[self.smsModel rac_startGetVcodeWithFetchVcodeSignal:sig andPhone:self.currentPhone] subscribeError:^(NSError *error) {
        
        [gToast showError:error.domain];
        
    }];
}


#pragma mark - LazyLoad

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
