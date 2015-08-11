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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - Action
- (void)actionGetVcode:(id)sender
{
    @weakify(self);
    RACSignal *signal = [self.smsModel rac_getUnbindCZBVcode];
    [[self.smsModel rac_startGetVcodeWithFetchVcodeSignal:signal] subscribeNext:^(id x) {
       
        @strongify(self);
        self.promptString = [self attrStrWithPhone:gAppMgr.myUser.userID];
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
        self.promptString = [self attrStrWithError:error];
        [self.tableView reloadData];
    }];
}

- (IBAction)actionUnbind:(id)sender
{
    ResultVC *vc = [UIStoryboard vcWithId:@"ResultVC" inStoryboard:@"Bank"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.presentedFormSheetSize = CGSizeMake(self.view.frame.size.width - 60, 238);
    formSheet.cornerRadius = 2.0;
    formSheet.shadowOpacity = 0.01;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.shouldCenterVertically = YES;
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        [vc.drawView drawSuccess];
        [[vc.confirmBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [formSheet dismissAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
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
    lb.attributedText = self.promptString;

    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normalCell" forIndexPath:indexPath];
    
    UITextField *textfield = (UITextField *)[cell.contentView viewWithTag:1002];
    UIButton *vcodeBtn = (UIButton *)[cell.contentView viewWithTag:1003];
    if (!self.vcodeButton) {
        self.vcodeButton = vcodeBtn;
        self.smsModel.getVcodeButton = vcodeBtn;
        [self.smsModel countDownIfNeededWithVcodeType:HKVcodeTypeUnbindCZB];
        [vcodeBtn addTarget:self action:@selector(actionGetVcode:) forControlEvents:UIControlEventTouchUpInside];
        [self actionGetVcode:vcodeBtn];
    }
    if (!self.vcodeField) {
        self.vcodeField = textfield;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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

@end
