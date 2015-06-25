//
//  RegisterVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "RegisterVC.h"
#import "XiaoMa.h"
#import "UIView+Shake.h"
#import "HKSMSModel.h"
#import "GetVcodeOp.h"
#import "UpdatePwdOp.h"
#import "WebVC.h"

@interface RegisterVC () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *checkBox;
@property (weak, nonatomic) IBOutlet UIButton *vcodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *registBtn;
@property (nonatomic, strong) HKSMSModel *smsModel;
@property (weak, nonatomic) IBOutlet UITextField *num;
@property (weak, nonatomic) IBOutlet UITextField *code;
@property (weak, nonatomic) IBOutlet UITextField *pwd;
@end

@implementation RegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.smsModel = [[HKSMSModel alloc] initWithTokenPool:self.model.tokenPool];
    
    self.num.delegate = self;
    self.code.delegate = self;
    self.pwd.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp004"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp004"];
}

#pragma mark - Action
- (IBAction)actionGetVCode:(id)sender
{
    [MobClick event:@"rp004-2"];
    if ([self sharkCellIfErrorAtIndex:0]) {
        return;
    }
    [[self.smsModel rac_handleVcodeButtonClick:sender withVcodeType:3 phone:[self textAtIndex:0]]
     subscribeError:^(NSError *error) {
        [gToast showError:error.domain];
    }];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1001];
    [field becomeFirstResponder];
}

- (IBAction)actionCheck:(id)sender
{
    [MobClick event:@"rp004-5"];
    self.checkBox.selected = !self.checkBox.selected;
    self.registBtn.enabled = self.checkBox.selected;
}

- (IBAction)actionAgreement:(id)sender
{
    [MobClick event:@"rp004-6"];
    WebVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"WebVC"];
    vc.title = @"服务协议";
    vc.url = @"http://www.xiaomadada.com/apphtml/license.html";
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionRegister:(id)sender
{
    [MobClick event:@"rp004-7"];
    if ([self sharkCellIfErrorAtIndex:0]) {
        return;
    }
    if ([self sharkCellIfErrorAtIndex:1]) {
        return;
    }
    if ([self sharkCellIfErrorAtIndex:2]) {
        return;
    }
    NSString *pwd = [self textAtIndex:2];
    if (pwd.length < 6 || pwd.length  > 32) {
        [gToast showText:@"请输入6-32位的密码"];
        return;
    }
    [self.view endEditing:YES];
    NSString *ad = [self textAtIndex:0];
    NSString *vcode = [self textAtIndex:1];
    NSString *newpwd = [self textAtIndex:2];
    @weakify(self);
    [[[[self.model.loginModel rac_loginWithAccount:ad validCode:vcode] flattenMap:^RACStream *(id value) {

        UpdatePwdOp *op = [UpdatePwdOp new];
        op.req_newPwd = newpwd;
        return [[op rac_postRequest] catch:^RACSignal *(NSError *error) {
            return [RACSignal return:nil];
        }];
    }] initially:^{
        
        [gToast showingWithText:@"正在注册..."];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [gToast dismiss];
        [self.model dismissForTargetVC:self forSucces:YES];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
    
    //激活验证码的输入框
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1001];
    [field becomeFirstResponder];
}

#pragma mark - TextField
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.num) {
        [MobClick event:@"rp004-1"];
    }
    if (textField == self.code) {
        [MobClick event:@"rp004-3"];
    }
    if (textField == self.pwd) {
        [MobClick event:@"rp004-4"];
    }
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
