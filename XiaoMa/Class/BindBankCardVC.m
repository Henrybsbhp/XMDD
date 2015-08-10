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

#pragma mark - Action
- (void)actionGetVCode:(id)sender
{
    if ([self sharkCellIfErrorAtIndex:1]) {
        return;
    }
    RACSignal *sig = [self.smsModel rac_getBindCZBVcodeWithCardno:self.cardField.text phone:self.phoneField.text];
    [[self.smsModel rac_startGetVcodeWithFetchVcodeSignal:sig] subscribeError:^(NSError *error) {
        [gToast showError:error.domain];
    }];
    
    //激活输入验证码的输入框
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1001];
    [field becomeFirstResponder];
}

- (IBAction)actionBind:(id)sender {
    if ([self sharkCellIfErrorAtIndex:0]) {
        return;
    }
    if ([self sharkCellIfErrorAtIndex:1]) {
        return;
    }
    if ([self sharkCellIfErrorAtIndex:2]) {
        return;
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
    if (!self.vcodeField) {
        self.vcodeField = field;
    }
    return cell;
}

#pragma mark - Private
- (NSString *)textAtIndex:(NSInteger)index
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1001];
    return field.text;
}

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
