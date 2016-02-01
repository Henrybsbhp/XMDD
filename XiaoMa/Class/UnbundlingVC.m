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
#import "BankCardStore.h"

static NSString *s_sendedPhone;

@interface UnbundlingVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIButton *vcodeButton;
@property (nonatomic, strong) UITextField *vcodeField;
@property (nonatomic, strong) HKSMSModel *smsModel;
@property (nonatomic, strong) NSAttributedString *promptString;
@property (nonatomic, strong) UIView *headerView;
@end

@implementation UnbundlingVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"UnbundlingVC dealloc!");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.smsModel = [[HKSMSModel alloc] init];
}


#pragma mark - Action
- (void)actionGetVcode:(id)sender
{
    [MobClick event:@"rp329-2"];
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
    [MobClick event:@"rp329-3"];
    if ([self sharkCellIfErrorAtIndex:0]) {
        return;
    }
    BankCardStore *store = [BankCardStore fetchOrCreateStore];
    @weakify(self);
    [[[[store sendEvent:[store deleteBankCardByCID:self.card.cardID vcode:self.vcodeField.text]] signal] initially:^{
        
        [gToast showingWithText:@"正在解绑..."];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [gToast dismiss];
        [ResultVC showInTargetVC:self withSuccessText:@"解绑成功!" ensureBlock:^{
            [MobClick event:@"rp329-4"];
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
    if (!self.headerView) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        UILabel * lb = [[UILabel alloc] initWithFrame:CGRectZero];
        lb.numberOfLines = 2;
        lb.lineBreakMode = NSLineBreakByWordWrapping;
        lb.font = [UIFont systemFontOfSize:14];
        lb.textColor = [UIColor darkGrayColor];
        lb.backgroundColor = [UIColor clearColor];
        lb.tag = 1001;
        headerView.backgroundColor = [UIColor clearColor];
        [headerView addSubview:lb];
        [lb mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(headerView.mas_left).offset(16);
            make.centerY.equalTo(headerView.mas_centerY).offset(6);
            make.size.height.mas_equalTo(36);
            make.right.equalTo(headerView.mas_right).offset(-16);
        }];
        self.headerView = headerView;
    }

    UILabel *lb = (UILabel *)[self.headerView viewWithTag:1001];
    @weakify(self);
    [[RACObserve(self, promptString) takeUntil:[self.headerView rac_signalForSelector:@selector(prepareForReuse)]]
     subscribeNext:^(id x) {
        @strongify(self);
        lb.attributedText = self.promptString;
    }];


    return self.headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normalCell" forIndexPath:indexPath];
    
    UITextField *textfield = (UITextField *)[cell.contentView viewWithTag:1001];
    UIButton *vcodeBtn = (UIButton *)[cell.contentView viewWithTag:1002];
    
    [[[textfield rac_signalForControlEvents:UIControlEventEditingDidBegin] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        [MobClick event:@"rp329-1"];
    }];
    
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
