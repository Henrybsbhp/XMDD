//
//  BindBankCardVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BindBankCardVC.h"
#import "BankCardStore.h"
#import "HKSMSModel.h"
#import "UIView+Shake.h"
#import "BindBankcardOp.h"
#import "WebVC.h"
#import "ResultVC.h"
#import "MyCarStore.h"
#import "CKLimitTextField.h"
#import <UIKitExtension.h>

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
@end

@implementation BindBankCardVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.smsModel = [[HKSMSModel alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"rp313"];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [MobClick endLogPageView:@"rp313"];
    [super viewWillDisappear:animated];
}

#pragma mark - Action
- (void)actionGetVCode:(id)sender
{
    [MobClick event:@"rp313-3"];
    if (self.cardField.text.length < 15 || self.cardField.text.length > 20) {
        [self shakeCellAtIndex:0];
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
                [self.promptView setHidden:NO animated:YES];
            });
            return [RACSignal return:nil];
        }
        return [RACSignal error:error];
    }];
    [[self.smsModel rac_startGetVcodeWithFetchVcodeSignal:sig] subscribeNext:^(id x) {
       
        @strongify(self);
        self.promptView.hidden = YES;
    } error:^(NSError *error) {
        
        @strongify(self);
        [self.promptView setHidden:YES animated:NO];
        if (error.code == 616102) {
            UIAlertView *alert = [[UIAlertView alloc] initNoticeWithTitle:@"" message:@"该卡已绑定当前账号,请勿重复绑定"
                                                        cancelButtonTitle:@"确定"];
            [alert show];
        }
        else {
            [gToast showError:error.domain];
        }
    }];
    
    //激活输入验证码的输入框
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1001];
    [field becomeFirstResponder];
}

- (IBAction)actionCheck:(id)sender
{
    [MobClick event:@"rp003-7"];
    self.checkButton.selected = !self.checkButton.selected;
    self.bindButton.enabled = self.checkButton.selected;
}

- (IBAction)actionAgreement:(id)sender
{
    WebVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"WebVC"];
    vc.title = @"服务协议";
    vc.url = kCZBankLicenseUrl;
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)actionBind:(id)sender {
    [MobClick event:@"rp313-5"];
    if (self.cardField.text.length < 15 || self.cardField.text.length > 20) {
        [self shakeCellAtIndex:0];
        return;
    }
    if (self.phoneField.text.length != 11) {
        [self shakeCellAtIndex:1];
        return;
    }
    if (self.vcodeField.text.length < 4 || self.vcodeField.text.length > 8) {
        [self shakeCellAtIndex:2];
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
        [ResultVC showInTargetVC:self withSuccessText:@"恭喜，绑定成功!" ensureBlock:^{
            [MobClick event:@"rp313-6"];
            [self.navigationController popViewControllerAnimated:YES];
            BankCardStore *store = [BankCardStore fetchExistsStore];
            [store sendEvent:[store getAllBankCards]];
            MyCarStore *carStore = [MyCarStore fetchExistsStore];
            [[carStore getAllCars] send];
            [self postCustomNotificationName:kNotifyRefreshMyBankcardList object:nil];
            if (self.finishAction)
            {
                self.finishAction();
            }
        }];
    } error:^(NSError *error) {

        [gToast showError:error.domain];
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 74;
    }
    if (indexPath.row == 1) {
        return 68;
    }
    return 78;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [self bankCardCellAtIndexPath:indexPath];
    }
    else if (indexPath.row == 1) {
        return [self phoneCellAtIndexPath:indexPath];
    }
    return [self vcodeCellAtIndexPath:indexPath];
}

#pragma mark - About Cell
- (UITableViewCell *)bankCardCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CardCell" forIndexPath:indexPath];
    CKLimitTextField *field = (CKLimitTextField *)[cell.contentView viewWithTag:1001];
    if (!self.cardField) {
        self.cardField = field;
        field.textLimit = 20;
        
        [field setDidBeginEditingBlock:^(CKLimitTextField *field) {
            [MobClick event:@"rp313-1"];
        }];
    }
    return cell;
}

- (UITableViewCell *)phoneCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PhoneCell" forIndexPath:indexPath];
    CKLimitTextField *phoneField = (CKLimitTextField *)[cell.contentView viewWithTag:1001];
    UIButton *vcodeButton = (UIButton *)[cell.contentView viewWithTag:1002];

    if (!self.vcodeButton) {
        self.vcodeButton = vcodeButton;
        self.smsModel.getVcodeButton = vcodeButton;
        [vcodeButton addTarget:self action:@selector(actionGetVCode:) forControlEvents:UIControlEventTouchUpInside];
        [self.smsModel countDownIfNeededWithVcodeType:HKVcodeTypeBindCZB];
    }
    
    if (!self.phoneField) {
        self.phoneField = phoneField;
        phoneField.text = gAppMgr.myUser.phoneNumber.length > 0 ? gAppMgr.myUser.phoneNumber : gAppMgr.myUser.userID;
        self.smsModel.phoneField = phoneField;
        vcodeButton.enabled = phoneField.text.length == 11;
        phoneField.textLimit = 11;
        
        [phoneField setDidBeginEditingBlock:^(CKLimitTextField *field) {
            [MobClick event:@"rp313-2"];
        }];
        
        @weakify(self);
        [phoneField setTextDidChangedBlock:^(CKLimitTextField *field) {
            @strongify(self);
            NSString *title = [self.vcodeButton titleForState:UIControlStateNormal];
            if ([@"获取验证码" equalByCaseInsensitive:title]) {
                BOOL enable = field.text.length == 11;
                if (enable != self.vcodeButton.enabled) {
                    self.vcodeButton.enabled = enable;
                }
            }
        }];
    }
    
    return cell;
}

- (UITableViewCell *)vcodeCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"VcodeCell" forIndexPath:indexPath];
    CKLimitTextField *field = (CKLimitTextField *)[cell.contentView viewWithTag:1001];

    if (!self.vcodeField) {
        self.vcodeField = field;
        field.textLimit = 8;
        [field setDidBeginEditingBlock:^(CKLimitTextField *field) {
            [MobClick event:@"rp313-4"];
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

- (void)shakeCellAtIndex:(NSInteger)index
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    UIView *container = [cell.contentView viewWithTag:100];
    [container shake];
}

@end
