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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.textFeild becomeFirstResponder];
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
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain
                                                             target:self action:@selector(requestModifyUserInfo)];
    [right setTitleTextAttributes:@{
                                    NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:14.0]
                                    } forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = right;
    
    self.navigationItem.title = self.naviTitle;
    
    self.textFeild.delegate = self;
}

- (void)setupUI
{
    [self.bgView setBorderLineInsets:UIEdgeInsetsMake(-1, 0, -1, 0) forDirectionMask:CKViewBorderDirectionBottom & CKViewBorderDirectionTop];
    [self.bgView showBorderLineWithDirectionMask:CKViewBorderDirectionBottom & CKViewBorderDirectionTop];
    [self.bgView setBorderLineColor:kDarkLineColor forDirectionMask:CKViewBorderDirectionBottom & CKViewBorderDirectionTop];
    
    self.textFeild.placeholder = self.placeholder;
    self.textFeild.text = self.content;
    self.textFeild.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textFeild.textColor = kDefTintColor;
}


#pragma mark - Action
- (void)requestModifyUserInfo
{
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


@end
