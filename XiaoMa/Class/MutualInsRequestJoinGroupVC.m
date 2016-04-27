//
//  MutuallnsRequestJoinGroupVC.m
//  XiaoMa
//
//  Created by St.Jimmy on 3/18/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "MutualInsRequestJoinGroupVC.h"
#import "MutualInsGroupInfoVC.h"
#import "SearchCooperationGroupOp.h"
#import "SJKeyboardManager.h"
#import "IQKeyboardManager.h"

@interface MutualInsRequestJoinGroupVC () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *bottomView;
@property (nonatomic, copy) NSString *textFieldString;

@property (nonatomic, strong) UITextField *groupTextField;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *bottomConstraint;


@end

@implementation MutualInsRequestJoinGroupVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"MutualInsRequestJoinGroupVC deallocated");
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (IOSVersionGreaterThanOrEqualTo(@"8.0")) {
        self.tableView.estimatedRowHeight = 26;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    [self setupBottomView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.groupTextField resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)setupBottomView
{
    UIButton *confirmButton = (UIButton *)[self.bottomView viewWithTag:111];
    
    confirmButton.layer.cornerRadius = 5.0f;
    confirmButton.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirmButtonClicked:(id)sender
{
    [self requestJoinGroup:self.textFieldString];
}

- (void)requestJoinGroup:(NSString *)cipher
{
    SearchCooperationGroupOp * op = [SearchCooperationGroupOp operation];
    op.req_cipher = cipher;
    
    @weakify(self)
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithoutText];
        
    }] subscribeNext:^(SearchCooperationGroupOp * rop) {
        
        @strongify(self)
        [gToast dismiss];
        MutualInsGroupInfoVC * vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutualInsGroupInfoVC"];
        vc.originVC = self.originVC;
        vc.groupId = rop.rsp_groupid;
        vc.groupCreateName = rop.rsp_creatorname;
        vc.groupName = rop.rsp_name;
        vc.cipher = rop.rsp_cipher;
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];

}

#pragma mark - UITableViewDelegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        
        return 1;
        
    } else if (section == 1) {
        
        return 1;
        
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        
        return 67;
        
    }
    
    if (IOSVersionGreaterThanOrEqualTo(@"8.0")) {
        
        return UITableViewAutomaticDimension;
        
    }
    
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    [cell layoutIfNeeded];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
    return ceil(size.height + 1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        
        return 10;
        
    } else if (section == 1) {
        
        return CGFLOAT_MIN;
        
    }
    
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            cell = [self loadCipherBannerCellAtIndexPath:indexPath];
            
        }
        
    } else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            
            cell = [self loadTipsCellAtIndexPath:indexPath];
            
        }
        
    }
    
    return cell;
}

- (UITableViewCell *)loadCipherBannerCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CipherBannerCell"];
    
    UITextField *cipherTextField = (UITextField *)[cell.contentView viewWithTag:101];
    self.groupTextField = cipherTextField;
//    [cipherTextField becomeFirstResponder];
    cipherTextField.delegate = self;
    // 设置 cipherTextField 左侧留白
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 19, 20)];
    cipherTextField.leftView = paddingView;
    cipherTextField.leftViewMode = UITextFieldViewModeAlways;
    
    [cipherTextField setBorderColor:HEXCOLOR(@"#ECEDED")];
    [cipherTextField setBorderWidth:1];
    [cipherTextField setCornerRadius:1];
    cipherTextField.layer.masksToBounds = YES;
    
    @weakify(self)
    [cipherTextField.rac_textSignal subscribeNext:^(id x) {
        
        @strongify(self)
        self.textFieldString = x;
    }];
    
    return cell;
}

- (UITableViewCell *)loadTipsCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TipsCell"];
    
    UILabel *tipsLabel1 = (UILabel *)[cell.contentView viewWithTag:107];
    UILabel *tipsLabel2 = (UILabel *)[cell.contentView viewWithTag:108];
    UILabel *tipsLabel3 = (UILabel *)[cell.contentView viewWithTag:109];
    UILabel *tipsLabel4 = (UILabel *)[cell.contentView viewWithTag:110];
    
    [tipsLabel1 setPreferredMaxLayoutWidth:gAppMgr.deviceInfo.screenSize.width - 100];
    [tipsLabel2 setPreferredMaxLayoutWidth:gAppMgr.deviceInfo.screenSize.width - 100];
    [tipsLabel3 setPreferredMaxLayoutWidth:gAppMgr.deviceInfo.screenSize.width - 100];
    [tipsLabel4 setPreferredMaxLayoutWidth:gAppMgr.deviceInfo.screenSize.width - 100];
    tipsLabel1.attributedText = [self generateAttributedStringWithLineSpacing:@"1、您需要输入正确暗号，并确认团队信息。"];
    tipsLabel2.attributedText = [self generateAttributedStringWithLineSpacing:@"2、确认本团信息后，选择车辆后即可入团。"];
    tipsLabel3.attributedText = [self generateAttributedStringWithLineSpacing:@"3、完善资料，填写信息后我们将对您的信息进行审核。"];
    tipsLabel4.attributedText = [self generateAttributedStringWithLineSpacing:@"4、选择购买的服务种类，方便我们为您精准报价。"];
    
    return cell;
    
}

// 生成带有行高的 NSAttributedString
- (NSAttributedString *)generateAttributedStringWithLineSpacing:(NSString *)string
{
    NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentJustified;
    style.lineSpacing = 4.0f;
    
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:string attributes:@{ NSParagraphStyleAttributeName : style}];
    
    return attrText;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [[SJKeyboardManager sharedManager] initWithViewController:self view:self.view textField:textField bottomLayoutConstraint:self.bottomConstraint bottomView:self.bottomView];
}


@end
