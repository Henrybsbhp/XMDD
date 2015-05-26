//
//  MineVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/4.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MineVC.h"
#import "XiaoMa.h"
#import "GetUserBaseInfoOp.h"
#import "MyCarListVC.h"
#import "MyOrderListVC.h"
#import "MyCouponVC.h"
#import "MyInfoViewController.h"
#import "AboutViewController.h"
#import "MessageListVC.h"
#import "MyCollectionViewController.h"
#import "CouponPkgViewController.h"

@interface MineVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel *PlaceholdLabel;

@end

@implementation MineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBgView];
    [self observeUserInfo];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //如果当前视图的导航条没有发生跳转，则不做处理
    if (![self.navigationController.topViewController isEqual:self]) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
}

- (void)setupBgView
{
    @weakify(self);
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.view.mas_top).offset(0);
    }];
    
    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc] init];
    [self.bgView addGestureRecognizer:gesture];
    self.bgView.userInteractionEnabled = YES;
    [[gesture rac_gestureSignal] subscribeNext:^(id x) {
        
        if([LoginViewModel loginIfNeededForTargetViewController:self])
        {
            MyInfoViewController * vc = [mineStoryboard instantiateViewControllerWithIdentifier:@"MyInfoViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
    
    [[RACObserve(gAppMgr.myUser, avatar) distinctUntilChanged] subscribeNext:^(UIImage * avatar) {
        
        self.avatarView.image = avatar;
    }];
    [[RACObserve(gAppMgr.myUser, userName) distinctUntilChanged] subscribeNext:^(NSString * name) {
        
        self.nameLabel.text = name;
    }];
}

- (void)refreshAvatarView
{
    if (gAppMgr.myUser.avatarUrl.length)
    {
    [[gMediaMgr rac_getPictureForUrl:gAppMgr.myUser.avatarUrl withDefaultPic:@"cm_avatar"] subscribeNext:^(UIImage * image) {
        
        gAppMgr.myUser.avatar = image;
        self.avatarView.image = image;
    }];
    }
    else
    {
        self.avatarView.image = [UIImage imageNamed:@"cm_avatar"];
    }
}

- (void)observeUserInfo
{
    @weakify(self);
    [[RACObserve(gAppMgr, myUser) distinctUntilChanged] subscribeNext:^(id x) {
        @strongify(self);
        [self reloadUserInfo];
        
        JTUser * user = gAppMgr.myUser;
        self.nameLabel.text = gAppMgr.myUser.userName;
        self.nameLabel.hidden = !gAppMgr.myUser;
        self.accountLabel.text = gAppMgr.myUser.userID;
        self.accountLabel.hidden = !gAppMgr.myUser;
        self.PlaceholdLabel.hidden = gAppMgr.myUser ? YES : NO;
        [self refreshAvatarView];
        [self.tableView reloadData];
    }];
}

- (void)reloadUserInfo
{
    [[GetUserBaseInfoOp rac_fetchUserBaseInfo] subscribeNext:^(GetUserBaseInfoOp *op) {
        [self refreshAvatarView];
        self.nameLabel.text = gAppMgr.myUser ? (gAppMgr.myUser.userName ? gAppMgr.myUser.userName : @"——") : @"未登录";
        self.accountLabel.text = gAppMgr.myUser.userID ? gAppMgr.myUser.userID : @"——";
        [self.tableView reloadData];
    }];
}

#pragma mark - Action
-(void)actionPushToTickets
{
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        
        MyCouponVC *vc = [UIStoryboard vcWithId:@"MyCouponVC" inStoryboard:@"Mine"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionPushToMessages
{
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        MessageListVC *vc = [UIStoryboard vcWithId:@"MessageListVC" inStoryboard:@"Mine"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Table view data source
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 2) {
        return 3;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [self topCellAtIndexPath:indexPath];
    }
    cell = [self normalCellAtIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 9;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 64;
    }
    return 44;
}
                                                
- (UITableViewCell *)topCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TopCell" forIndexPath:indexPath];
//    UILabel *leftTitleL = (UILabel *)[cell.contentView viewWithTag:1001];
    UIButton *leftBtn = (UIButton *)[cell.contentView viewWithTag:1002];
//    UILabel *rightTitleL = (UILabel *)[cell.contentView viewWithTag:2001];
    UIButton *rightBtn = (UIButton *)[cell.contentView viewWithTag:2002];

//    leftTitleL.text = @"优惠券";
    @weakify(self);
    [[[leftBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        [self actionPushToTickets];
    }];
    
    [[[rightBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        [self actionPushToMessages];
    }];
    return cell;
}

- (UITableViewCell *)normalCellAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
    UIImageView *iconV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *subTitleL = (UILabel *)[cell.contentView viewWithTag:1003];
    subTitleL.text = nil;
    if (indexPath.section == 1) {
        iconV.image = [UIImage imageNamed:@"me_car"];
        titleL.text = @"爱车";
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            iconV.image = [UIImage imageNamed:@"me_order"];
            titleL.text = @"订单";
        }
        else if (indexPath.row == 1) {
            iconV.image = [UIImage imageNamed:@"me_collect"];
            titleL.text = @"礼包";
        }
        else if (indexPath.row == 2) {
            iconV.image = [UIImage imageNamed:@"me_collect"];
            titleL.text = @"收藏";
        }
    }
    else if (indexPath.section == 3) {
        iconV.image = [UIImage imageNamed:@"me_setting"];
        titleL.text = @"关于";
    }
    cell.customSeparatorInset = UIEdgeInsetsMake(0, 12, 0, 0);
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[JTTableViewCell class]]) {
        [(JTTableViewCell *)cell prepareCellForTableView:tableView atIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
            MyCarListVC *vc = [UIStoryboard vcWithId:@"MyCarListVC" inStoryboard:@"Mine"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 0) {
        if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
            MyOrderListVC *vc = [UIStoryboard vcWithId:@"MyOrderListVC" inStoryboard:@"Mine"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 1)
    {
        if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
            CouponPkgViewController *vc = [mineStoryboard instantiateViewControllerWithIdentifier:@"CouponPkgViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 2)
    {
        if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
            MyCollectionViewController *vc = [mineStoryboard instantiateViewControllerWithIdentifier:@"MyCollectionViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if (indexPath.section == 3)
    {
        AboutViewController * vc = [mineStoryboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
