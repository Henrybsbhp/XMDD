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
#import "NSString+PhoneNumber.h"
#import "CKLimitTextField.h"
#import "IQKeyboardManager.h"

@interface VcodeLoginVC () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *checkBox;
@property (weak, nonatomic) IBOutlet UIButton *vcodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
@property (nonatomic, strong) HKSMSModel *smsModel;
@property (weak, nonatomic) IBOutlet CKLimitTextField *num;
@property (weak, nonatomic) IBOutlet VCodeInputField *code;
@property (nonatomic, assign) CGFloat upOffsetY;
@property (nonatomic, strong) NSString *currentPhone;

@end

@implementation VcodeLoginVC

- (void)awakeFromNib
{
    self.model = [[LoginViewModel alloc] init];
    self.router.navigationBarHidden = YES;
    self.router.disableInteractivePopGestureRecognizer = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Login_backgroundImage.png"]];
    [backgroundImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = backgroundImageView;
    
    self.smsModel = [[HKSMSModel alloc] init];

    NSArray *mobEvents = @[@"rp002_7",@"rp002_8",@"rp002_9"];
    
    self.smsModel.getVcodeButton = self.vcodeBtn;
    self.smsModel.inputVcodeField = self.code;
    self.smsModel.phoneField = self.num;
    [self.smsModel setupWithTargetVC:self mobEvents:mobEvents];
    [self.smsModel countDownIfNeededWithVcodeType:HKVcodeTypeLogin];
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 设置 tableView 的 inset，这样可以让 tableView 和 Status Bar 保持一定距离。
    [self.tableView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.num resignFirstResponder];
    [self.code resignFirstResponder];
}

- (void)dealloc
{
    DebugLog(@"VcodeLoginVC dealloc");
}

- (void)setupUI
{
    self.num.textLimit = 11;
    @weakify(self);
    [self.num setDidBeginEditingBlock:^(CKLimitTextField *field) {
        
         @strongify(self);
        [MobClick event:@"rp002_1"];
        if ([self isIphone4OrLess]) {
            
        } else if (self.view.frame.origin.y >= 0) {
            [self setViewMovedUp:YES];
        }
    }];
    
    [self.num setDidEndEditingBlock:^(CKLimitTextField *textField) {
        
        @strongify(self);
        if ([self isIphone4OrLess]) {
            
        } else if (self.view.frame.origin.y < 0) {
            [self setViewMovedUp:NO];
        }
    }];
    
    
    [self.num setTextDidChangedBlock:^(CKLimitTextField *field) {
        @strongify(self);
        NSString *title = [self.vcodeBtn titleForState:UIControlStateNormal];
        if ([@"获取验证码" equalByCaseInsensitive:title]) {
            BOOL enable = field.text.length == 11;
            if (enable != self.vcodeBtn.enabled) {
                self.vcodeBtn.enabled = enable;
            }
        }
        if (self.currentPhone && ![self.currentPhone isEqualToString:field.text]) {
            [self.code hideRightView];
        }
    }];

    [self.vcodeBtn setTitleColor:kDefTintColor forState:UIControlStateNormal];
    
    [self.vcodeBtn setTitleColor:HEXCOLOR(@"#CFDBD3") forState:UIControlStateDisabled];
    
    self.code.textLimit = 8;
    
    
    [self.code setDidEndEditingBlock:^(CKLimitTextField *textField) {
        
        @strongify(self);
        if (self.view.frame.origin.y < 0) {
            [self setViewMovedUp:NO];
        }
    }];
    
    [self.code setDidBeginEditingBlock:^(CKLimitTextField *field) {
        
        @strongify(self);
        [MobClick event:@"rp002_3"];
        if  (self.view.frame.origin.y >= 0) {
            [self setViewMovedUp:YES];
        }
    }];
}

// 点击验证码 textField 后，如登录按钮被遮住，则提升 view 的高度。
- (void)setViewMovedUp:(BOOL)movedUp
{
    
    [UIView animateWithDuration:0.4f animations:^{
        
        CGRect rect = self.view.frame;
        
        if (movedUp) {
            
            CGFloat offsetY = self.view.frame.size.height - 367 - 84;
            self.upOffsetY = 260 - offsetY;
            if (self.upOffsetY >= 0) {
                rect.origin.y -= self.upOffsetY;
                rect.size.height += self.upOffsetY;
            }
            
            
        } else {
            if (self.upOffsetY >= 0) {
                rect.origin.y = 0;
                rect.size.height -= self.upOffsetY;
            }
            
        }
        
        self.view.frame = rect;
        
    }];
   
}

// 判断是否为 iPhone 4/4s 或更为早先的设备
- (BOOL)isIphone4OrLess
{
    BOOL isIphone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    CGFloat screenWidth =[[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat screenMaxLength = MAX(screenWidth, screenHeight);
    BOOL isIphone4OrLess = isIphone && screenMaxLength < 568.0;
    
    return isIphone4OrLess;
}

#pragma mark - Action
- (IBAction)actionCloseButton:(id)sender
{
    self.loginSuccessAction = nil;
    [self.model dismissForTargetVC:self forSucces:NO];
}

- (IBAction)actionGetVCode:(id)sender
{
    [MobClick event:@"rp002_2"];
    if ([self sharkCellIfErrorAtIndex:1]) {
        return;
    }

    self.currentPhone = [self textAtIndex:1];
    RACSignal *sig = [self.smsModel rac_getSystemVcodeWithType:HKVcodeTypeLogin phone:self.currentPhone];
    [[self.smsModel rac_startGetVcodeWithFetchVcodeSignal:sig andPhone:self.currentPhone] subscribeError:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
    
    //激活输入验证码的输入框
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1001];
    [field becomeFirstResponder];
}

- (IBAction)actionCheck:(id)sender
{
    [MobClick event:@"rp002_4"];
    self.checkBox.selected = !self.checkBox.selected;
    self.bottomBtn.enabled = self.checkBox.selected;
    if (self.bottomBtn.enabled == NO) {
        self.bottomBtn.backgroundColor = [UIColor colorWithHTMLExpression:@"#CFDBD3"];
    } else {
        self.bottomBtn.backgroundColor = [UIColor colorWithHTMLExpression:@"#18D06A"];
    }
}

- (IBAction)actionAgreement:(id)sender
{
    [MobClick event:@"rp002_5"];
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.title = @"服务协议";
    vc.url = kServiceLicenseUrl;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionLogin:(id)sender
{
    [MobClick event:@"rp002_6"];
    if (![self.num.text isPhoneNumber]) {
        [self shakeCellAtIndex:1];
        return;
    }
    if (self.code.text.length < 4) {
        [self shakeCellAtIndex:2];
        return;
    }
    
    [self.view endEditing:YES];
    NSString *ad = [self textAtIndex:1];
    NSString *vcode = [self textAtIndex:2];
    @weakify(self);
    [[[self.model.loginModel rac_loginWithAccount:ad validCode:vcode] initially:^{
        [gToast showingWithText:@"正在登录..."];
    }] subscribeNext:^(id x) {
        @strongify(self);
        [gToast dismiss];
        [self.model dismissForTargetVC:self forSucces:YES];
        
        if (self.loginSuccessAction)
        {
            self.loginSuccessAction();
        }
    
        self.loginSuccessAction = nil;
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

- (void)shakeCellAtIndex:(NSInteger)index
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    UIView *container = [cell.contentView viewWithTag:100];
    [container shake];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

@end
