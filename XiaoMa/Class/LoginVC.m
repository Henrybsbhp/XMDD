//
//  LoginVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "LoginVC.h"
#import "XiaoMa.h"
#import "UIView+Shake.h"
#import "UIBarButtonItem+CustomStyle.h"
#import "RegisterVC.h"
#import "ResetPasswordVC.h"
#import "VcodeLoginVC.h"

@interface LoginVC () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *num;
@property (weak, nonatomic) IBOutlet UITextField *code;
@end

@implementation LoginVC

- (void)awakeFromNib {
    self.model = [[LoginViewModel alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
    self.navigationItem.leftBarButtonItem = back;
    
    self.num.delegate = self;
    self.code.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp001"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp001"];
    [self.view endEditing:YES];
}

- (void)actionBack:(id)sender {
    [self.model dismissForTargetVC:self forSucces:NO];
}

#pragma mark - Action
- (IBAction)actionLoginByVCode:(id)sender
{
    [MobClick event:@"rp001-5"];
    VcodeLoginVC *vc = [UIStoryboard vcWithId:@"VcodeLoginVC" inStoryboard:@"Login"];
    vc.model = self.model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionRegister:(id)sender
{
    [MobClick event:@"rp001-3"];
    RegisterVC *vc = [UIStoryboard vcWithId:@"RegisterVC" inStoryboard:@"Login"];
    vc.model = self.model;
    [self.navigationController pushViewController:vc animated:YES];

}

- (IBAction)actionResetPwd:(id)sender
{
    [MobClick event:@"rp001-6"];
    ResetPasswordVC *vc = [UIStoryboard vcWithId:@"ResetPasswordVC" inStoryboard:@"Login"];
    vc.model = self.model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionLogin:(id)sender
{
    [MobClick event:@"rp001-4"];
    if ([self sharkCellIfErrorAtIndex:0]) {
        return;
    }
    if ([self sharkCellIfErrorAtIndex:1]) {
        return;
    }
    [self.view endEditing:YES];
    NSString *ad = [self textAtIndex:0];
    NSString *pwd = [self textAtIndex:1];
    @weakify(self);
    [[[self.model.loginModel rac_loginWithAccount:ad password:pwd] initially:^{
        [gToast showingWithText:@"正在登录..."];
    }] subscribeNext:^(id x) {
        @strongify(self);
        [gToast showSuccess:@"登录成功"];
        [self.model dismissForTargetVC:self forSucces:YES];
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}

#pragma mark - TextField
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.num) {
        [MobClick event:@"rp001-1"];
    }
    if (textField == self.code) {
        [MobClick event:@"rp001-2"];
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
