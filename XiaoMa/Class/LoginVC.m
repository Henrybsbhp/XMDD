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

@interface LoginVC ()
@end

@implementation LoginVC

- (void)awakeFromNib {
    self.model = [LoginViewModel new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)actionBack:(id)sender {
    [self.model dismissForTargetVC:self forSucces:NO];
}

#pragma mark - Action
- (IBAction)actionLoginByVCode:(id)sender
{
    VcodeLoginVC *vc = [UIStoryboard vcWithId:@"VcodeLoginVC" inStoryboard:@"Login"];
    vc.model = self.model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionRegister:(id)sender
{
    RegisterVC *vc = [UIStoryboard vcWithId:@"RegisterVC" inStoryboard:@"Login"];
    vc.model = self.model;
    [self.navigationController pushViewController:vc animated:YES];

}

- (IBAction)actionResetPwd:(id)sender
{
    ResetPasswordVC *vc = [UIStoryboard vcWithId:@"ResetPasswordVC" inStoryboard:@"Login"];
    vc.model = self.model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionLogin:(id)sender
{
    if ([self sharkCellIfErrorAtIndex:0]) {
        return;
    }
    if ([self sharkCellIfErrorAtIndex:1]) {
        return;
    }
    NSString *ad = [self textAtIndex:0];
    NSString *pwd = [self textAtIndex:1];
    @weakify(self);
    [[[self.model.loginModel rac_loginWithAccount:ad password:pwd] initially:^{
        [gToast showingWithText:@"正在登陆..."];
    }] subscribeNext:^(id x) {
        @strongify(self);
        [gToast showSuccess:@"登陆成功"];
        [self.model dismissForTargetVC:self forSucces:YES];
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
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
