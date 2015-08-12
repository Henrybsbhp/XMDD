//
//  UnbundlingVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/8/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UnbundlingVC.h"
#import "ResultVC.h"
#import "DrawingBoardView.h"
#import "HKSMSModel.h"
#import "HKConvertModel.h"
#import "JTLabel.h"
#import "UnbindBankcardOp.h"
#import "UIView+Shake.h"

static NSString *s_sendedPhone;

@interface UnbundlingVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIButton *vcodeButton;
@property (nonatomic, strong) UITextField *vcodeField;
@property (nonatomic, strong) HKSMSModel *smsModel;
@property (nonatomic, strong) NSAttributedString *promptString;

@end

@implementation UnbundlingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.smsModel = [[HKSMSModel alloc] init];
}

#pragma mark - Action
- (void)actionGetVcode:(id)sender
{
    @weakify(self);
    RACSignal *signal = [self.smsModel rac_getUnbindCZBVcode];
    [[self.smsModel rac_startGetVcodeWithFetchVcodeSignal:signal] subscribeNext:^(id x) {
       
        @strongify(self);
        NSString *phone = gAppMgr.myUser.userID;
        s_sendedPhone = phone;
        self.promptString = [self attrStrWithPhone:phone];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
        self.promptString = [self attrStrWithError:error];
    }];
}

- (IBAction)actionUnbind:(id)sender
{
    if ([self sharkCellIfErrorAtIndex:0]) {
        return;
    }
    UnbindBankcardOp *op = [UnbindBankcardOp operation];
    op.req_vcode = self.vcodeField.text;
    op.req_cardid = self.card.cardID;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"正在解绑..."];
        
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [gToast dismiss];
        [ResultVC showInTargetVC:self withSuccessText:@"解绑成功!" ensureBlock:^{
            [self.navigationController popToViewController:self.originVC animated:YES];
            [self postCustomNotificationName:kNotifyRefreshMyBankcardList object:nil];
        }];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
  
}
#pragma mark - TableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView * headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"HeaderView"];
    if (!headerView) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"HeaderView"];
        JTLabel * lb = [[JTLabel alloc] init];
        lb.numberOfLines = 0;
        lb.font = [UIFont systemFontOfSize:14];
        lb.textColor = [UIColor darkGrayColor];
        lb.backgroundColor = [UIColor clearColor];
        lb.tag = 1001;
        [headerView addSubview:lb];
        [lb mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(headerView.mas_left).offset(16);
            make.centerY.equalTo(headerView.mas_centerY).offset(6);
            make.right.equalTo(headerView.mas_right).offset(8);
        }];
    }
    
    UILabel *lb = (UILabel *)[headerView viewWithTag:1001];
    @weakify(self);
    [[RACObserve(self, promptString) takeUntil:[headerView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {

        @strongify(self);
        lb.attributedText = self.promptString;
    }];


    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normalCell" forIndexPath:indexPath];
    
    UITextField *textfield = (UITextField *)[cell.contentView viewWithTag:1001];
    UIButton *vcodeBtn = (UIButton *)[cell.contentView viewWithTag:1002];
    if (!self.vcodeButton) {
        self.vcodeButton = vcodeBtn;
        self.smsModel.getVcodeButton = vcodeBtn;
        [vcodeBtn addTarget:self action:@selector(actionGetVcode:) forControlEvents:UIControlEventTouchUpInside];
        //如果按钮倒计时已经结束，就开始发送短信
        if ([self.smsModel countDownIfNeededWithVcodeType:HKVcodeTypeUnbindCZB]) {
            [self actionGetVcode:vcodeBtn];
        }
        //否则显示发送的手机号码
        else {
            self.promptString = [self attrStrWithPhone:s_sendedPhone];
        }
    }
    if (!self.vcodeField) {
        self.vcodeField = textfield;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
     
#pragma mark - Utility
- (NSAttributedString *)attrStrWithError:(NSError *)error
{
    return [[NSAttributedString alloc] initWithString:error.domain attributes:nil];
}
     
- (NSAttributedString *)attrStrWithPhone:(NSString *)phone
{
    phone = [HKConvertModel convertPhoneNumberForEncryption:phone];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"已发送验证码至" attributes:nil];
    [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:phone attributes:@{NSForegroundColorAttributeName:HEXCOLOR(@"#23ac2d")}]];
    [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"，请输入验证码解绑~" attributes:nil]];
    return attrStr;
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
