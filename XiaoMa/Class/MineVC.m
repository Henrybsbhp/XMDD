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
#import "MyCouponVC.h"
#import "MyInfoViewController.h"
#import "AboutViewController.h"


@interface MineVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;

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
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
        
        MyInfoViewController * vc = [mineStoryboard instantiateViewControllerWithIdentifier:@"MyInfoViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    [[RACObserve(gAppMgr.myUser, avatar) distinctUntilChanged] subscribeNext:^(UIImage * avatar) {
        
        self.avatarView.image = avatar;
    }];
    [[RACObserve(gAppMgr.myUser, userName) distinctUntilChanged] subscribeNext:^(NSString * name) {
        
        self.nameLabel.text = name;
    }];
}

- (void)observeUserInfo
{
    @weakify(self);
    [[RACObserve(gAppMgr, myUser) distinctUntilChanged] subscribeNext:^(id x) {
        @strongify(self);
        [self reloadUserInfo];
    }];
}

- (void)reloadUserInfo
{
    [[GetUserBaseInfoOp rac_fetchUserBaseInfo] subscribeNext:^(GetUserBaseInfoOp *op) {
        [[gMediaMgr rac_getPictureForUrl:gAppMgr.myUser.avatarUrl withDefaultPic:@"cm_avatar"]
         subscribeNext:^(id x) {
//            self.avatarView.image = x;
             gAppMgr.myUser.avatar = x;
        }];
        self.nameLabel.text = gAppMgr.myUser ? (gAppMgr.myUser.userName ? gAppMgr.myUser.userName : @"——") : @"未登录";
        self.accountLabel.text = gAppMgr.myUser.userID ? gAppMgr.myUser.userID : @"——";
        [self.tableView reloadData];
    }];
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
        return 2;
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
    UILabel *leftTitleL = (UILabel *)[cell.contentView viewWithTag:1001];
    UIButton *leftBtn = (UIButton *)[cell.contentView viewWithTag:1002];
    [leftBtn addTarget:self action:@selector(pushToTickets) forControlEvents:UIControlEventTouchUpInside];
    UILabel *rightTitleL = (UILabel *)[cell.contentView viewWithTag:2001];
    UIButton *rightBtn = (UIButton *)[cell.contentView viewWithTag:2002];
    
    leftTitleL.text = @"优惠券";
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
//        else if (indexPath.row == 1) {
//            iconV.image = [UIImage imageNamed:@"me_bank"];
//            titleL.text = @"银行卡";
//            [[RACObserve(gAppMgr.myUser, abcCarwashesCount) takeUntilForCell:cell] subscribeNext:^(NSNumber *x) {
//                int count = [x intValue];
//                subTitleL.text = count > 0 ? [NSString stringWithFormat:@"免费洗车%d次", count] : nil;
//            }];
//        }
        else if (indexPath.row == 1) {
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
    
    if (indexPath.section == 3)
    {
        AboutViewController * vc = [mineStoryboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }

}

-(void)pushToTickets
{
    MyCouponVC *vc = [UIStoryboard vcWithId:@"MyCouponVC" inStoryboard:@"Mine"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
