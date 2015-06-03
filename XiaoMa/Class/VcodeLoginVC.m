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
#import "WebVC.h"

@interface VcodeLoginVC ()
@property (weak, nonatomic) IBOutlet UIButton *checkBox;
@property (weak, nonatomic) IBOutlet UIButton *vcodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
@property (nonatomic, strong) HKSMSModel *smsModel;
@end

@implementation VcodeLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.smsModel = [HKSMSModel new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)actionGetVCode:(id)sender
{
    if ([self sharkCellIfErrorAtIndex:0]) {
        return;
    }
    [[self.smsModel rac_handleVcodeButtonClick:sender withVcodeType:3 phone:[self textAtIndex:0]]
     subscribeNext:^(GetVcodeOp *op) {
         gNetworkMgr.token = op.req_token;
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}

- (IBAction)actionCheck:(id)sender
{
    self.checkBox.selected = !self.checkBox.selected;
    self.bottomBtn.enabled = self.checkBox.selected;
}

- (IBAction)actionAgreement:(id)sender
{
    WebVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"WebVC"];
    vc.title = @"服务协议";
    vc.url = @"http://www.xiaomadada.com/apphtml/license.html";
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
