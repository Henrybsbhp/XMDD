//
//  CreateGroupVC.m
//  XiaoMa
//
//  Created by St.Jimmy on 3/16/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "CreateGroupVC.h"
#import "CreateGroupOp.h"
#import "ApplyCooperationGroupOp.h"
#import <QuartzCore/QuartzCore.h>
#import "InviteCompleteVC.h"
#import "InviteByCodeVC.h"
#import "MutualInsPicUpdateVC.h"
#import "HKImageAlertVC.h"
#import "MutualInsStore.h"
#import "SJKeyboardManager.h"
#import "IQKeyboardManager.h"
#import "MutualInsPickCarVC.h"
#import "MutualInsGroupDetailVC.h"
#import "GetCooperationUsercarListOp.h"

@interface CreateGroupVC () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *bottomView;

@property (nonatomic, copy) NSString *textFieldString;
@property (nonatomic, copy) NSString *groupNameString;
@property (nonatomic, strong) UITextField *groupTextField;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (nonatomic, assign) CGFloat upOffsetY;
@property (nonatomic, assign) CGRect originRect;

@property (nonatomic)BOOL isLoadingGroupName;

@end

@implementation CreateGroupVC

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"CreateGroupVC deallocated");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (IOSVersionGreaterThanOrEqualTo(@"8.0")) {
        self.tableView.estimatedRowHeight = 136;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    // 设置底部含有「确认」按钮的 UIView
    [self setupButtomView];
    
    [self requestGetGroupName];
    
    self.originRect = self.view.frame;
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
    
}


- (void)viewDidDisappear:(BOOL)animated
{
    [IQKeyboardManager sharedManager].enable = YES;
}


#pragma mark - Setup
- (void)setupButtomView
{
    UIButton *confirmButton = (UIButton *)[self.bottomView viewWithTag:112];
    confirmButton.layer.cornerRadius = 5.0f;
    confirmButton.clipsToBounds = YES;
}


#pragma mark -  Action
- (IBAction)confirmButtonDidClick:(id)sender
{
    if (self.textFieldString.length)
        [self.groupTextField resignFirstResponder];
        [self requestCreateGroup:self.textFieldString];
}

// 骰子 Button 触发事件，来随机获取 Group 名，获取到以后将 Button 隐藏。
- (IBAction)diceButtonDidClick:(UIButton *)sender
{
    [self requestGetGroupName];
}

- (void)actionBack:(id)sender
{
    if (self.originVC) {
        [self.navigationController popToViewController:self.originVC animated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)jumpToPickCarVCWithGroupID:(NSNumber *)groupId
{
    GetCooperationUsercarListOp * op = [[GetCooperationUsercarListOp alloc] init];
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"获取车辆数据中..." inView:self.view];
    }] subscribeNext:^(GetCooperationUsercarListOp * x) {
        
        [gToast dismissInView:self.view];
        if (x.rsp_carArray.count)
        {
            MutualInsPickCarVC * vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutualInsPickCarVC"];
            vc.mutualInsCarArray = x.rsp_carArray;
            [vc setFinishPickCar:^(HKMyCar *car) {
                
                [self jumpToUpdateInfoVC:car andGroupId:groupId];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            [self jumpToUpdateInfoVC:nil andGroupId:groupId];
        }
    } error:^(NSError *error) {
        
        [gToast showError:@"获取失败，请重试" inView:self.view];
    }];
}

- (void)jumpToInviteByCodeVC:(NSNumber *)groupId
{
    InviteByCodeVC * vc = [UIStoryboard vcWithId:@"InviteByCodeVC" inStoryboard:@"MutualInsJoin"];
    vc.groupId = groupId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToGroupOnVC:(NSNumber *)groupId
{
    MutualInsGroupDetailVC *vc = [[MutualInsGroupDetailVC alloc] init];
    vc.router.userInfo = [[CKDict alloc] init];
    vc.router.userInfo[kMutInsGroupID] = groupId;
    [self.router.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToHomePage
{
    if (self.router.userInfo[kOriginRoute])
    {
        UIViewController *vc = [self.router.userInfo[kOriginRoute] targetViewController];
        [self.router.navigationController popToViewController:vc animated:YES];
    }
    else
    {
        CKRouter * route = [self.router.navigationController.routerList objectForKey:@"MutualInsVC"];
        if (route)
        {
            [self.router.navigationController popToViewController:route.navigationController animated:YES];
        }
        else
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (void)jumpToUpdateInfoVC:(HKMyCar *)car andGroupId:(NSNumber *)groupId
{
    MutualInsPicUpdateVC * vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutualInsPicUpdateVC"];
    vc.curCar = car;
    vc.memberId = nil;// 挑选车说明没有memberId
    vc.groupId = groupId;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Utilitly
- (void)showAlertView:(NSString *)groupName andCipher:(NSString *)cipher andGroupId:(NSNumber *)groupId
{
    InviteCompleteVC * alertVC = [[InviteCompleteVC alloc] init];
    alertVC.datasource = @[@{@"title":@"本团名称",@"content":groupName},@{@"title":@"本团暗号",@"content":cipher,@"color":@"#ff7428"}];
    alertVC.datasource2 = @[@"您可以继续完善自己的资料，或者邀请好友参团"];
    @weakify(alertVC);
    [alertVC setCloseAction:^{
        
        @strongify(alertVC);
        [alertVC dismiss];
        [self jumpToHomePage];
    }];
    HKAlertActionItem *invite = [HKAlertActionItem itemWithTitle:@"邀请好友" color:kDefTintColor clickBlock:nil];
    HKAlertActionItem *complete = [HKAlertActionItem itemWithTitle:@"完善资料" color:kDefTintColor clickBlock:nil];
    alertVC.actionItems = @[invite, complete];
    [alertVC showWithActionHandler:^(NSInteger index, HKAlertVC *alertView) {
        
        [alertView dismiss];
        if (index) {
            
            [self jumpToPickCarVCWithGroupID:groupId];
        }
        else {
            
            [self jumpToInviteByCodeVC:groupId];
        }

    }];
}

- (void)requestGetGroupName
{
    ApplyCooperationGroupOp * op = [[ApplyCooperationGroupOp alloc] init];
    [[[op rac_postRequest] initially:^{
        
        self.isLoadingGroupName = YES;
    }] subscribeNext:^(ApplyCooperationGroupOp * rop) {
        
        self.isLoadingGroupName = NO;
        self.groupNameString = rop.rsp_name;
    } error:^(NSError *error) {
        
        self.isLoadingGroupName = NO;
    }];
}

- (void)requestCreateGroup:(NSString *)groupNameToCreate
{
    CreateGroupOp *op = [[CreateGroupOp alloc] init];
    op.req_name = groupNameToCreate;
    
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"建团中..."];
    }] subscribeNext:^(CreateGroupOp *rop) {
        
        [gToast dismiss];
        [[[MutualInsStore fetchExistsStore] reloadSimpleGroups] send];
        [self showAlertView:groupNameToCreate andCipher:rop.rsp_cipher andGroupId:rop.rsp_groupid];
        
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
        return 2;
    } else if (section == 1) {
        return 1;
    }
    
    return 1;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
        
            cell = [self loadBannerCellAtIndexPath:indexPath];
        
        } else if (indexPath.row == 1) {
        
            cell = [self loadGroupNameInputCellAtIndexPath:indexPath];
        
        }
        
    } else if (indexPath.section == 1) {
        
        cell = [self loadTipsCellAtIndexPath:indexPath];
        
    }
    
    return cell;
}

- (UITableViewCell *)loadBannerCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BannerCell"];
    
    UILabel *infoLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UIImageView *notesImageView = (UIImageView *)[cell.contentView viewWithTag:102];
    
    notesImageView.image = [UIImage imageNamed:@"mutuallns_createGroup_notes"];
    infoLabel.text = @"立即组团";
    
    cell.backgroundColor = [UIColor colorWithHTMLExpression:@"#18d06a"];
    
    return cell;
}

- (UITableViewCell *)loadGroupNameInputCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"GroupNameInputCell"];
    
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UITextField *groupTextField = (UITextField *)[cell.contentView viewWithTag:102];
    self.groupTextField = groupTextField;
    groupTextField.delegate = self;
    UIActivityIndicatorView * indicatorView = (UIActivityIndicatorView *)[cell.contentView viewWithTag:103];
    UIButton *diceButton = (UIButton *)[cell.contentView viewWithTag:112];

    
    titleLabel.text = @"团队名称";
    
    // 设置 groupTextField 的左边留白
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 19, 20)];
    groupTextField.leftView = paddingView;
    groupTextField.leftViewMode = UITextFieldViewModeAlways;
    
    groupTextField.layer.borderColor = [[UIColor colorWithHTMLExpression:@"#EEEFEF"] CGColor];
    groupTextField.layer.cornerRadius = 1;
    groupTextField.layer.borderWidth = 1;
    groupTextField.layer.masksToBounds = YES;
    groupTextField.text = self.textFieldString;
    
    @weakify(self)
    [groupTextField.rac_textSignal subscribeNext:^(id x) {
        
        @strongify(self)
        self.textFieldString = x;
    }];
    
    [[[RACObserve(self, groupNameString) distinctUntilChanged] filter:^BOOL(NSString * value) {
      
        return value.length;
    }] subscribeNext:^(id x) {
       
        @strongify(self)
        groupTextField.text = x;
        self.textFieldString = x;
    }];

    [[RACObserve(self, isLoadingGroupName) distinctUntilChanged] subscribeNext:^(NSNumber * number) {
        
        BOOL isloading = [number boolValue];
        indicatorView.animating = isloading;
        indicatorView.hidden = !isloading;
        
        // 如果刷新停止后，则让骰子 Button 显现。
        diceButton.hidden = isloading;
    }];
    
    return cell;
}

- (UITableViewCell *)loadTipsCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TipsCell"];
    
    UILabel *tipsTitleLabel = (UILabel *)[cell.contentView viewWithTag:105];
    UIImageView *tipsImageView1 = (UIImageView *)[cell.contentView viewWithTag:106];
    UIImageView *tipsImageView2 = (UIImageView *)[cell.contentView viewWithTag:107];
    UIImageView *tipsImageView3 = (UIImageView *)[cell.contentView viewWithTag:108];
    UILabel *tipsLabel1 = (UILabel *)[cell.contentView viewWithTag:109];
    UILabel *tipsLabel2 = (UILabel *)[cell.contentView viewWithTag:110];
    UILabel *tipsLabel3 = (UILabel *)[cell.contentView viewWithTag:111];
    
    
    tipsImageView1.image = [UIImage imageNamed:@"mutuallns_createGroup_click"];
    tipsImageView2.image = [UIImage imageNamed:@"mutuallns_createGroup_share"];
    tipsImageView3.image = [UIImage imageNamed:@"mutuallns_createGroup_rectangle"];
    
    tipsTitleLabel.text = @"组团提示";
    [tipsLabel1 setPreferredMaxLayoutWidth:gAppMgr.deviceInfo.screenSize.width - 106];
    [tipsLabel2 setPreferredMaxLayoutWidth:gAppMgr.deviceInfo.screenSize.width - 106];
    [tipsLabel3 setPreferredMaxLayoutWidth:gAppMgr.deviceInfo.screenSize.width - 106];
    tipsLabel1.attributedText = [self generateAttributedStringWithLineSpacing:@"输入团队名称后，点击下方 “确定” 即可发起组团并获得入团暗号。"];
    tipsLabel2.attributedText = [self generateAttributedStringWithLineSpacing:@"分享暗号可以邀请好友加入。"];
    tipsLabel3.attributedText = [self generateAttributedStringWithLineSpacing:@"建团后，您也可以选择完善信息后，再去邀请好友参团。"];
    
    
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

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [[SJKeyboardManager sharedManager] moveUpWithViewController:self view:self.view textField:textField bottomLayoutConstraint:self.bottomConstraint bottomView:self.bottomView];
}



@end
