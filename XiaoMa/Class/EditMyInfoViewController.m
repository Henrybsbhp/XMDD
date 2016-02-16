//
//  EditMyInfoViewController.m
//  XiaoMa
//
//  Created by jt on 15-5-11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "EditMyInfoViewController.h"
#import "UIView+Layer.h"
#import "UpdateUserInfoOp.h"

@interface EditMyInfoViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UITextField *textFeild;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

@implementation EditMyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    [self setupUI];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DebugLog(@"EditMyInfoViewController dealloc");
}

#pragma mark - SetupUI
- (void)setupNavigationBar
{
    UIBarButtonItem *commitBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(requestModifyUserInfo)];
    self.navigationItem.rightBarButtonItem = commitBtn;
    
    self.navigationItem.title = self.naviTitle;
    
    self.textFeild.delegate = self;
}

- (void)setupUI
{
    [self.bgView setBorderLineInsets:UIEdgeInsetsMake(-1, 0, -1, 0) forDirectionMask:CKViewBorderDirectionBottom & CKViewBorderDirectionTop];
    [self.bgView showBorderLineWithDirectionMask:CKViewBorderDirectionBottom & CKViewBorderDirectionTop];
    [self.bgView setBorderLineColor:HEXCOLOR(@"#e0e0e0") forDirectionMask:CKViewBorderDirectionBottom & CKViewBorderDirectionTop];
    
    self.textFeild.placeholder = self.placeholder;
    self.textFeild.text = self.content;
    self.textFeild.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [self.textFeild becomeFirstResponder];
}


#pragma mark - Action
- (void)requestModifyUserInfo
{
    [MobClick event:@"rp305-2"];
    UpdateUserInfoOp * op = [UpdateUserInfoOp operation];
    if (self.type == ModifyNickname)
    {
        
        if (self.textFeild.text.length == 0)
        {
            [gToast showError:@"请输入昵称"];
            return;
        }
        op.nickname = self.textFeild.text;
    }
    
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"修改中…"];
    }] subscribeNext:^(UpdateUserInfoOp * op) {
        
        [gToast showSuccess:@"修改成功"];
        
        if (self.type == ModifyNickname)
        {
            gAppMgr.myUser.userName = self.textFeild.text;
        }
        [self.navigationController popViewControllerAnimated:YES];
    } error:^(NSError *error) {
        
        [gToast showError:@"修改失败，再试一次"];
    }];
}

- (void)viewTap
{
    [self.textFeild becomeFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [MobClick event:@"rp305-3"];
}

@end
