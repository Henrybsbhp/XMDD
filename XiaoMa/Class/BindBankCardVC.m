//
//  BindBankCardVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BindBankCardVC.h"
#import "BankStore.h"
#import "HKSMSModel.h"
#import "UIView+Shake.h"
#import "BindBankcardOp.h"
#import "ResultVC.h"
#import "MyCarStore.h"
#import "CKLimitTextField.h"
#import <UIKitExtension.h>
#import "HKTableViewCell.h"
#import "HKImageAlertVC.h"

@interface BindBankCardVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *promptView;
@property (weak, nonatomic) IBOutlet UIButton *bindButton;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (nonatomic, strong) UITextField *phoneField;
@property (nonatomic, strong) UITextField *cardField;
@property (nonatomic, strong) UITextField *vcodeField;
@property (nonatomic, strong) UIButton *vcodeButton;
@property (nonatomic, strong) HKSMSModel *smsModel;
@property (nonatomic) BOOL firstRowVisible;

@property (nonatomic, strong) HKImageAlertVC *alert;

@end

@implementation BindBankCardVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"BindBankCardVC dealloc!");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.smsModel = [[HKSMSModel alloc] init];
    
    if (IOSVersionGreaterThanOrEqualTo(@"8.0")) {
        self.tableView.estimatedRowHeight = 26;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.firstRowVisible = NO;
}


#pragma mark - Action
- (void)actionGetVCode:(id)sender
{
    [MobClick event:@"rp313_3"];
    if (self.cardField.text.length < 15 || self.cardField.text.length > 20) {
        [self shakeCellAtIndex:0 section:0];
        return;
    }
    CKAsyncMainQueue(^{
        [self.view endEditing:YES];
    });
    @weakify(self);
    RACSignal *sig = [self.smsModel rac_getBindCZBVcodeWithCardno:self.cardField.text phone:self.phoneField.text];
    sig = [sig catch:^RACSignal *(NSError *error) {
        
        @strongify(self);
        if (error.code == 616103) {
            CKAfter(0.35, ^{
//                [self.promptView setHidden:NO animated:YES];
                _firstRowVisible = !_firstRowVisible;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
                UITextField *field = (UITextField *)[cell.contentView viewWithTag:1001];
                [field becomeFirstResponder];
                
            });
            return [RACSignal return:nil];
        }
        return [RACSignal error:error];
    }];
    [[self.smsModel rac_startGetVcodeWithFetchVcodeSignal:sig] subscribeNext:^(id x) {
       
        @strongify(self);
//        self.promptView.hidden = YES;
        _firstRowVisible = NO;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    } error:^(NSError *error) {
        
        @strongify(self);
//        [self.promptView setHidden:YES animated:NO];
        _firstRowVisible = NO;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if (error.code == 616102) {
            
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#18d06a") clickBlock:^(id alertVC) {
                [alertVC dismiss];
            }];
            HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_error" Message:@"该卡已绑定当前账号,请勿重复绑定" ActionItems:@[cancel]];
            [alert show];
            
        }
        else {
            [gToast showError:error.domain];
        }
    }];
    
    //激活输入验证码的输入框
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1001];
    [field becomeFirstResponder];
}

- (IBAction)actionCheck:(id)sender
{
    [MobClick event:@"rp003_7"];
    self.checkButton.selected = !self.checkButton.selected;
    self.bindButton.enabled = self.checkButton.selected;
    
    if (self.bindButton.enabled == NO) {
        self.bindButton.backgroundColor = [UIColor colorWithHTMLExpression:@"#CFDBD3"];
    } else {
        self.bindButton.backgroundColor = [UIColor colorWithHTMLExpression:@"#18D06A"];
    }
}

- (IBAction)actionAgreement:(id)sender
{
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.title = @"服务协议";
    vc.url = kCZBankLicenseUrl;
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)actionBind:(id)sender {
    [MobClick event:@"rp313_5"];
    if (self.cardField.text.length < 15 || self.cardField.text.length > 20) {
        [self shakeCellAtIndex:0 section:0];
        return;
    }
    if (self.phoneField.text.length != 11) {
        [self shakeCellAtIndex:1 section:0];
        return;
    }
    if (self.vcodeField.text.length < 4 || self.vcodeField.text.length > 8) {
        [self shakeCellAtIndex:1 section:1];
        return;
    }
    BindBankcardOp *op = [BindBankcardOp operation];
    op.req_bankcardno = self.cardField.text;
    op.req_phone = self.phoneField.text;
    op.req_vcode = self.vcodeField.text;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
    
        [gToast showingWithText:@"正在绑定..."];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [gToast dismiss];
        
//        TODO @hx
        
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确认" color:HEXCOLOR(@"#18d06a") clickBlock:^(id alertVC) {
            [alertVC dismiss];
            [gPhoneHelper makePhone:@"4007111111"];
            
            [MobClick event:@"rp313_6"];
            [self.navigationController popViewControllerAnimated:YES];
            BankStore *store = [BankStore fetchOrCreateStore];
            [[store getAllBankCards] sendAndIgnoreError];
            MyCarStore *carStore = [MyCarStore fetchExistsStore];
            [[carStore getAllCars] sendAndIgnoreError];
            [self postCustomNotificationName:kNotifyRefreshMyBankcardList object:nil];
            if (self.finishAction)
            {
                self.finishAction();
            }
        }];
        HKAlertVC *alert = [self alertWithTopTitle:@"恭喜，绑定成功" ImageName:@"mins_ok" Message:@"您现在可以使用该卡支付咯！" ActionItems:@[confirm]];
        [alert show];
    } error:^(NSError *error) {

        [gToast showError:error.domain];
    }];
}

-(HKImageAlertVC *)alertWithTopTitle:(NSString *)topTitle ImageName:(NSString *)imageName Message:(NSString *)message ActionItems:(NSArray *)actionItems
{
    if (!_alert)
    {
        _alert = [[HKImageAlertVC alloc]init];
    }
    _alert.topTitle = topTitle;
    _alert.imageName = imageName;
    _alert.message = message;
    _alert.actionItems = actionItems;
    return _alert;
}

// 移除 Section 的分割线
- (void)removeSectionSeparatorInHKTableViewCell:(HKTableViewCell *)cell;
{
    if (!cell.currentIndexPath ||
        [cell.targetTableView numberOfRowsInSection:cell.currentIndexPath.section] > cell.currentIndexPath.row+1) {
        
    } else {
        
        [cell removeBorderLineWithAlignment:CKLineAlignmentHorizontalBottom];
        
    }
    
    if (cell.currentIndexPath.row == 0) {
        
        [cell removeBorderLineWithAlignment:CKLineAlignmentHorizontalTop];
        
    }
    else {
        [cell removeBorderLineWithAlignment:CKLineAlignmentHorizontalTop];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        
        return 2;
        
    } else if (section == 1) {
        
        return 2;
        
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        return 48;
        
    } else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            
            if (IOSVersionGreaterThanOrEqualTo(@"8.0")) {
                
                return _firstRowVisible ? UITableViewAutomaticDimension : 0;
                
            }
            
            UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
            [cell layoutIfNeeded];
            [cell setNeedsUpdateConstraints];
            [cell updateConstraintsIfNeeded];
            CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
            
            return _firstRowVisible ? ceil(size.height + 1) : 0;
        }
        
    }
    return 132;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        
        return CGFLOAT_MIN;
        
    }
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return [self bankCardCellAtIndexPath:indexPath];
        }
        else if (indexPath.row == 1) {
            return [self phoneCellAtIndexPath:indexPath];
        }
        
    } else if (indexPath.section == 1) {
        
        if (indexPath.row == 0)  {
            
            return  [self alertCellAtIndexPath:indexPath];
            
        }
        
    }
    return [self vcodeCellAtIndexPath:indexPath];
}

#pragma mark - About Cell
- (UITableViewCell *)bankCardCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CardCell"];
    HKTableViewCell *hkCell = (HKTableViewCell *)cell;
    CKLimitTextField *field = (CKLimitTextField *)[hkCell.contentView viewWithTag:1001];
    if (!self.cardField) {
        self.cardField = field;
        field.textLimit = 20;
        
        [field setDidBeginEditingBlock:^(CKLimitTextField *field) {
            [MobClick event:@"rp313_1"];
        }];
    }
    
    hkCell.customSeparatorInset = UIEdgeInsetsMake(0, 18, 0, 0);
    [hkCell prepareCellForTableView:self.tableView atIndexPath:indexPath];
    [self removeSectionSeparatorInHKTableViewCell:hkCell];
    
    return hkCell;
}

- (UITableViewCell *)phoneCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PhoneCell" forIndexPath:indexPath];
    CKLimitTextField *phoneField = (CKLimitTextField *)[cell.contentView viewWithTag:1001];
//    UIButton *vcodeButton = (UIButton *)[cell.contentView viewWithTag:1002];
//
//    if (!self.vcodeButton) {
//        self.vcodeButton = vcodeButton;
//        self.smsModel.getVcodeButton = vcodeButton;
//        [vcodeButton addTarget:self action:@selector(actionGetVCode:) forControlEvents:UIControlEventTouchUpInside];
//        [self.smsModel countDownIfNeededWithVcodeType:HKVcodeTypeBindCZB];
//    }
    
    if (!self.phoneField) {
        self.phoneField = phoneField;
        phoneField.text = gAppMgr.myUser.phoneNumber.length > 0 ? gAppMgr.myUser.phoneNumber : gAppMgr.myUser.userID;
        self.smsModel.phoneField = phoneField;
        self.vcodeButton.enabled = phoneField.text.length == 11;
        phoneField.textLimit = 11;
        
        [phoneField setDidBeginEditingBlock:^(CKLimitTextField *field) {
            [MobClick event:@"rp313_2"];
        }];
        
        @weakify(self);
        [phoneField setTextDidChangedBlock:^(CKLimitTextField *field) {
            @strongify(self);
            NSString *title = [self.vcodeButton titleForState:UIControlStateNormal];
            if ([@"点击获取验证码" equalByCaseInsensitive:title]) {
                BOOL enable = field.text.length == 11;
                if (enable != self.vcodeButton.enabled) {
                    self.vcodeButton.enabled = enable;
                }
            }
        }];
    }
    
    return cell;
}

- (UITableViewCell *)alertCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"AlertCell"];
    
    return cell;
}

- (UITableViewCell *)vcodeCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"VcodeCell" forIndexPath:indexPath];
    CKLimitTextField *field = (CKLimitTextField *)[cell.contentView viewWithTag:1001];
    UIButton *vcodeButton = (UIButton *)[cell.contentView viewWithTag:1002];
    
    if (!self.vcodeButton) {
        self.vcodeButton = vcodeButton;
        self.smsModel.getVcodeButton = vcodeButton;
        [vcodeButton addTarget:self action:@selector(actionGetVCode:) forControlEvents:UIControlEventTouchUpInside];
        [self.smsModel countDownIfNeededWithVcodeType:HKVcodeTypeBindCZB];
    }
    
    field.layer.borderColor = [[UIColor colorWithHTMLExpression:@"#EEEFEF"] CGColor];
    field.layer.cornerRadius = 1;
    field.layer.borderWidth = 1;
    field.layer.masksToBounds = YES;

    if (!self.vcodeField) {
        self.vcodeField = field;
        field.textLimit = 8;
        [field setDidBeginEditingBlock:^(CKLimitTextField *field) {
            [MobClick event:@"rp313_4"];
        }];
    }
    return cell;
}

#pragma mark - Private
- (BOOL)sharkCellIfErrorAtIndex:(NSInteger)index
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1001];
    if (field.text.length == 0) {
        UIView *container = [cell.contentView viewWithTag:100];
        [container shake];
        return YES;
    }
    return NO;
}

- (void)shakeCellAtIndex:(NSInteger)index section:(NSInteger)section
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:section]];
    UIView *container = [cell.contentView viewWithTag:100];
    [container shake];
}

@end
