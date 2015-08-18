//
//  VcodeLoginVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/18.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "VcodeLoginVC.h"
#import "HKSMSModel.h"
#import "UIView+Shake.h"
#import "GetVcodeOp.h"
#import "VCodeInputField.h"
#import "WebVC.h"
#import "NSString+PhoneNumber.h"

@interface VcodeLoginVC () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *checkBox;
@property (weak, nonatomic) IBOutlet UIButton *vcodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
@property (nonatomic, strong) HKSMSModel *smsModel;
@property (weak, nonatomic) IBOutlet UITextField *num;
@property (weak, nonatomic) IBOutlet VCodeInputField *code;
@end

@implementation VcodeLoginVC

- (void)awakeFromNib
{
    self.model = [[LoginViewModel alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
    self.navigationItem.leftBarButtonItem = back;
    
    self.smsModel = [[HKSMSModel alloc] init];
    
    self.num.delegate = self;
    self.code.delegate = self;
    NSArray *mobEvents = @[@"rp002-7",@"rp002-8",@"rp002-9"];
    
    self.smsModel.getVcodeButton = self.vcodeBtn;
    self.smsModel.inputVcodeField = self.code;
    self.smsModel.phoneField = self.num;
    [self.smsModel setupWithTargetVC:self mobEvents:mobEvents];
    [self.smsModel countDownIfNeededWithVcodeType:HKVcodeTypeLogin];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp002"];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp002"];
}

#pragma mark - Action
- (void)actionBack:(id)sender {
    [self.model dismissForTargetVC:self forSucces:NO];
}

- (IBAction)actionGetVCode:(id)sender
{
    [MobClick event:@"rp002-2"];
    if ([self sharkCellIfErrorAtIndex:0]) {
        return;
    }
    
    RACSignal *sig = [self.smsModel rac_getSystemVcodeWithType:HKVcodeTypeLogin phone:[self textAtIndex:0]];
    [[self.smsModel rac_startGetVcodeWithFetchVcodeSignal:sig] subscribeError:^(NSError *error) {
        [gToast showError:error.domain];
    }];
    
    //激活输入验证码的输入框
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1001];
    [field becomeFirstResponder];
}

- (IBAction)actionCheck:(id)sender
{
    [MobClick event:@"rp002-4"];
    self.checkBox.selected = !self.checkBox.selected;
    self.bottomBtn.enabled = self.checkBox.selected;
}

- (IBAction)actionAgreement:(id)sender
{
    [MobClick event:@"rp002-5"];
    WebVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"WebVC"];
    vc.title = @"服务协议";
    vc.url = @"http://www.xiaomadada.com/apphtml/license.html";
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionLogin:(id)sender
{
    [MobClick event:@"rp002-6"];
    if (![self.num.text isPhoneNumber]) {
        [self shakeCellAtIndex:0];
        return;
    }
    if (self.code.text.length < 4) {
        [self shakeCellAtIndex:1];
        return;
    }
    
    [self.view endEditing:YES];
    NSString *ad = [self textAtIndex:0];
    NSString *vcode = [self textAtIndex:1];
    @weakify(self);
    [[[self.model.loginModel rac_loginWithAccount:ad validCode:vcode] initially:^{
        [gToast showingWithText:@"正在登录..."];
    }] subscribeNext:^(id x) {
        @strongify(self);
        [gToast dismiss];
        [self.model dismissForTargetVC:self forSucces:YES];
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}

#pragma mark - TextField
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.num) {
        [MobClick event:@"rp002-1"];
    }
    if (textField == self.code) {
        [MobClick event:@"rp002-3"];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //手机号输入
    if ([textField isEqual:self.num]) {
        NSInteger length = range.location + [string length] - range.length;
        if (length > 11) {
            return NO;
        }
        NSString *title = [self.vcodeBtn titleForState:UIControlStateNormal];
        if ([@"获取验证码" equalByCaseInsensitive:title]) {
            BOOL enable = length == 11;
            if (enable != self.vcodeBtn.enabled) {
                self.vcodeBtn.enabled = enable;
            }
        }
    }
    //验证码输入
    else if ([textField isEqual:self.code]) {
        NSInteger length = range.location + [string length] - range.length;
        if (length > 8) {
            return NO;
        }
    }
    
    return YES;
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

- (void)shakeCellAtIndex:(NSInteger)index
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    UIView *container = [cell.contentView viewWithTag:100];
    [container shake];
}

@end
