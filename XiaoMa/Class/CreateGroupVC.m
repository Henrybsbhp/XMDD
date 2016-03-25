//
//  CreateGroupVC.m
//  XiaoMa
//
//  Created by St.Jimmy on 3/16/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "CreateGroupVC.h"
#import "CreateGroupOp.h"
#import "MutualInsGrouponVC.h"
#import "ApplyCooperationGroupOp.h"
#import <QuartzCore/QuartzCore.h>
#import "InviteCompleteVC.h"
#import "InviteByCodeVC.h"
#import "MutualInsPicUpdateVC.h"
#import "CarListVC.h"
#import "ApplyCooperationGroupJoinOp.h"
#import "MutualInsHomeVC.h"
#import "EditCarVC.h"
#import "HKImageAlertVC.h"
#import "MutualInsStore.h"

@interface CreateGroupVC () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *bottomView;

@property (nonatomic, copy) NSString *textFieldString;
@property (nonatomic, copy) NSString *groupNameString;

@property (nonatomic)BOOL isLoadingGroupName;

@end

@implementation CreateGroupVC

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
        self.tableView.estimatedRowHeight = 26;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    // 设置底部含有「确认」按钮的 UIView
    [self setupButtomView];
    
    [self requestGetGroupName];
}

- (void)setupButtomView
{
    UIButton *confirmButton = (UIButton *)[self.bottomView viewWithTag:112];
    confirmButton.layer.cornerRadius = 5.0f;
    confirmButton.clipsToBounds = YES;
}

- (IBAction)confirmButtonDidClick:(id)sender
{
    if (self.textFieldString.length)
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestGetGroupName
{
    @weakify(self);
    ApplyCooperationGroupOp * op = [[ApplyCooperationGroupOp alloc] init];
    [[[op rac_postRequest] initially:^{
        
        @strongify(self)
        self.isLoadingGroupName = YES;
    }] subscribeNext:^(ApplyCooperationGroupOp * rop) {
        
        @strongify(self)
        self.isLoadingGroupName = NO;
        self.groupNameString = rop.rsp_name;
    } error:^(NSError *error) {
        
        @strongify(self)
        self.isLoadingGroupName = NO;
    }];
}

- (void)requestCreateGroup:(NSString *)groupNameToCreate
{
    @weakify(self);
    CreateGroupOp *op = [[CreateGroupOp alloc] init];
    op.req_name = groupNameToCreate;
    
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"建团中..."];
    }] subscribeNext:^(CreateGroupOp *rop) {
        
        @strongify(self)
        [gToast dismiss];
        [self showAlertView:groupNameToCreate andCipher:rop.rsp_cipher andGroupId:rop.rsp_groupid];
        
        [[[MutualInsStore fetchExistsStore] reloadSimpleGroups] sendAndIgnoreError];
        [MutualInsStore fetchExistsStore].lastGroupId = rop.rsp_groupid;
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
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
    HKAlertActionItem *invite = [HKAlertActionItem itemWithTitle:@"邀请好友" color:HEXCOLOR(@"#18d06a") clickBlock:nil];
    HKAlertActionItem *complete = [HKAlertActionItem itemWithTitle:@"完善资料" color:HEXCOLOR(@"#18d06a") clickBlock:nil];
    alertVC.actionItems = @[invite, complete];
    
    [alertVC showWithActionHandler:^(NSInteger index, HKAlertVC *alertView) {
        
        [alertView dismiss];
        if (index) {
            
            [self jumpToCarListVCWithGroupID:groupId groupName:groupName];
        }
        else {
            
            [self jumpToInviteByCodeVC:groupId];
        }

    }];
}

- (void)jumpToCarListVCWithGroupID:(NSNumber *)groupId groupName:(NSString *)groupname
{
    CarListVC *vc = [UIStoryboard vcWithId:@"CarListVC" inStoryboard:@"Car"];
    vc.title = @"选择爱车";
    vc.model.allowAutoChangeSelectedCar = YES;
    vc.model.disableEditingCar = YES; //不可修改
    vc.canJoin = YES; //用于控制爱车页面底部view
    vc.model.originVC = self.originVC;
    [vc setFinishPickActionForMutualIns:^(MyCarListVModel *carModel, UIView * loadingView) {
        
        //爱车页面入团按钮委托实现
        [self requestApplyJoinGroupWithID:groupId groupName:groupname carModel:carModel loadingView:loadingView];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToInviteByCodeVC:(NSNumber *)groupId
{
    InviteByCodeVC * vc = [UIStoryboard vcWithId:@"InviteByCodeVC" inStoryboard:@"MutualInsJoin"];
    vc.groupId = groupId;
    vc.originVC = self.originVC;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToGroupOnVC:(NSNumber *)groupId
{
    MutualInsGrouponVC *vc = [mutInsGrouponStoryboard instantiateViewControllerWithIdentifier:@"MutualInsGrouponVC"];
    HKMutualGroup * group = [[HKMutualGroup alloc] init];
    group.groupId = groupId;
    vc.group = group;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToHomePage
{
    [[[MutualInsStore fetchExistsStore] reloadSimpleGroups] sendAndIgnoreError];
    for (UIViewController * vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:NSClassFromString(@"MutualInsHomeVC")])
        {
            [self.navigationController popToViewController:vc animated:YES];
            return ;
        }
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)requestApplyJoinGroupWithID:(NSNumber *)groupId groupName:(NSString *)groupName
                           carModel:(MyCarListVModel *)carModel loadingView:(UIView *)view
{
    ApplyCooperationGroupJoinOp * op = [[ApplyCooperationGroupJoinOp alloc] init];
    op.req_groupid = groupId;
    op.req_carid = carModel.selectedCar.carId;
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"团队加入中..." inView:view];
    }] subscribeNext:^(ApplyCooperationGroupJoinOp * rop) {
        
        [gToast dismissInView:view];
        
        MutualInsPicUpdateVC * vc = [UIStoryboard vcWithId:@"MutualInsPicUpdateVC" inStoryboard:@"MutualInsJoin"];
        vc.originVC = self.originVC;
        vc.memberId = rop.rsp_memberid;
        vc.groupId = groupId;
        vc.groupName = groupName;
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
        if (error.code == 6115804) {
            [gToast dismissInView:view];
            HKImageAlertVC *alert = [[HKImageAlertVC alloc] init];
            alert.topTitle = @"温馨提示";
            alert.imageName = @"mins_bulb";
            alert.message = error.domain;
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:HEXCOLOR(@"#888888") clickBlock:^(id alertVC) {
                [alertVC dismiss];
            }];
            @weakify(self);
            HKAlertActionItem *improve = [HKAlertActionItem itemWithTitle:@"立即完善" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                @strongify(self);
                [alertVC dismiss];
                EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
                carModel.originVC = nil;  //设置为nil，返回爱车列表；或者用[UIStoryboard vcWithId:@"CarListVC" inStoryboard:@"Car"];
                vc.originCar = carModel.selectedCar;
                vc.model = carModel;
                [self.navigationController pushViewController:vc animated:YES];
            }];
            alert.actionItems = @[cancel, improve];
            [alert show];
        }
        else {
            [gToast showError:error.domain inView:view];
        }
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
    tipsLabel3.attributedText = [self generateAttributedStringWithLineSpacing:@"建团后，您也可以选择完善信息选择购买的小马互助种类后，再去邀请好友入团。"];
    
    
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



@end
