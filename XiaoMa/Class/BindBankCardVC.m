//
//  BindBankCardVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BindBankCardVC.h"
#import "HKSMSModel.h"
#import "UIView+Shake.h"
#import "BindBankcardOp.h"
#import "ResultVC.h"
#import <UIKitExtension.h>

@interface BindBankCardVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *promptView;
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
    if ([self sharkCellIfErrorAtIndex:0]) {
        return;
    }
    if ([self sharkCellIfErrorAtIndex:1]) {
        return;
    }
    @weakify(self);
    RACSignal *sig = [self.smsModel rac_getBindCZBVcodeWithCardno:self.cardField.text phone:self.phoneField.text];
    [[self.smsModel rac_startGetVcodeWithFetchVcodeSignal:sig] subscribeNext:^(id x) {
       
        @strongify(self);
        self.promptView.hidden = YES;
    } error:^(NSError *error) {
        
        @strongify(self);
        [self handleGetVcodeError:error];
    }];
    
    //激活输入验证码的输入框
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1001];
    [field becomeFirstResponder];
}

- (IBAction)actionBind:(id)sender {
    [MobClick event:@"rp313-5"];
    if ([self sharkCellIfErrorAtIndex:0]) {
        return;
    }
    if ([self sharkCellIfErrorAtIndex:1]) {
        return;
    }
    if ([self sharkCellIfErrorAtIndex:2]) {
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
        
        [gToast dismiss];
        @strongify(self);
        [ResultVC showInTargetVC:self withSuccessText:@"恭喜，绑定成功!" ensureBlock:^{
            [MobClick event:@"rp313-6"];
            [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - Handler
- (void)handleGetVcodeError:(NSError *)error
{
    if (error.code == 616103) {
        [self.promptView setHidden:NO animated:YES];
        return;
    }
    [self.promptView setHidden:YES animated:NO];
    if (error.code == 616102) {
        UIAlertView *alert = [[UIAlertView alloc] initNoticeWithTitle:@"" message:@"该卡已绑定当前账号,请勿重复绑定"
                                                    cancelButtonTitle:@"确定"];
        [alert show];
    }
    else {
        [gToast showError:error.domain];
    }
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
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1001];
    
    [[[field rac_signalForControlEvents:UIControlEventEditingDidBegin] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        [MobClick event:@"rp313-1"];
    }];
    if (!self.cardField) {
        self.cardField = field;
    }
    return cell;
}

- (UITableViewCell *)phoneCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PhoneCell" forIndexPath:indexPath];
    UITextField *phoneField = (UITextField *)[cell.contentView viewWithTag:1001];
    UIButton *vcodeButton = (UIButton *)[cell.contentView viewWithTag:1002];

    [[[phoneField rac_signalForControlEvents:UIControlEventEditingDidBegin] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        [MobClick event:@"rp313-2"];
    }];
    if (!self.phoneField) {
        self.phoneField = phoneField;
    }
    
    if (!self.vcodeButton) {
        self.vcodeButton = vcodeButton;
        self.smsModel.getVcodeButton = vcodeButton;
        [vcodeButton addTarget:self action:@selector(actionGetVCode:) forControlEvents:UIControlEventTouchUpInside];
        [self.smsModel countDownIfNeededWithVcodeType:HKVcodeTypeBindCZB];
    }
    
    return cell;
}

- (UITableViewCell *)vcodeCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"VcodeCell" forIndexPath:indexPath];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1001];
    [[[field rac_signalForControlEvents:UIControlEventEditingDidBegin] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        [MobClick event:@"rp313-4"];
    }];
    
    if (!self.vcodeField) {
        self.vcodeField = field;
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

@end
