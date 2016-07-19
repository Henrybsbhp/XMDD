//
//  MutualInsGroupInfoVC.m
//  XiaoMa
//
//  Created by St.Jimmy on 3/18/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "MutualInsGroupInfoVC.h"
#import "ApplyCooperationGroupJoinOp.h"
#import "PickCarVC.h"
#import "MutualInsPicUpdateVC.h"
#import "HKImageAlertVC.h"
#import "EditCarVC.h"
#import "MutualInsPickCarVC.h"
#import "GetCooperationUsercarListOp.h"
#import "MutualInsStore.h"

@interface MutualInsGroupInfoVC ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *bottomView;

@end

@implementation MutualInsGroupInfoVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"MutualInsGroupInfoVC deallocated");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (IOSVersionGreaterThanOrEqualTo(@"8.0")) {
        self.tableView.estimatedRowHeight = 26;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    [self setupBottomView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupBottomView
{
    UIButton *confirmButton = (UIButton *)[self.bottomView viewWithTag:106];
    
    confirmButton.layer.cornerRadius = 5.0f;
    confirmButton.clipsToBounds = YES;
}

- (IBAction)confirmButtonClicked:(id)sender
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
                
                if (car)
                {
                    [self requestApplyJoinGroupWithID:self.groupId carModel:car];
                }
                else
                {
                    [self jumpToUpdateInfoVC:nil andGroupId:self.groupId];
                }
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            [self jumpToUpdateInfoVC:nil andGroupId:self.groupId];
        }
    } error:^(NSError *error) {
        
        [gToast showError:@"获取失败，请重试" inView:self.view];
    }];
}

- (void)jumpToUpdateInfoVC:(NSNumber *)memberId andGroupId:(NSNumber *)groupId
{
    MutualInsPicUpdateVC * vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutualInsPicUpdateVC"];
    vc.originVC = self.originVC;
    vc.memberId = memberId;
    vc.groupId = groupId;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)requestApplyJoinGroupWithID:(NSNumber *)groupId carModel:(HKMyCar *)car
{
    ApplyCooperationGroupJoinOp * op = [[ApplyCooperationGroupJoinOp alloc] init];
    op.req_groupid = groupId;
    op.req_carid = car.carId;
    
    @weakify(self)
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"团队加入中..." inView:self.view];
    }] subscribeNext:^(ApplyCooperationGroupJoinOp * rop) {
        
        @strongify(self)
        [gToast dismissInView:self.view];
        
        /// 需要刷新团列表
        [[[MutualInsStore fetchExistsStore] reloadSimpleGroups] send];
        
        MutualInsPicUpdateVC * vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutualInsPicUpdateVC"];
        vc.memberId = rop.rsp_memberid;
        vc.groupId = groupId;
        vc.curCar = car;
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain inView:self.view];
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
            
            cell = [self loadInfoCellAtIndexPath:indexPath];
            
        }
        
    } else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            
            cell = [self loadJoinGroupFlowAtIndexPath:indexPath];
            
        }
        
    }
    
    return cell;
}

- (UITableViewCell *)loadBannerCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BannerCell"];
    
    return cell;
}

- (UITableViewCell *)loadInfoCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"InfoCell"];
    
    UILabel *groupNameLabel = (UILabel *)[cell.contentView viewWithTag:100];
    UILabel *nicknameLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *cipherLabel = (UILabel *)[cell.contentView viewWithTag:102];
    
    groupNameLabel.text = self.groupName;
    nicknameLabel.text = self.groupCreateName;
    cipherLabel.text = self.cipher;
    return cell;
}

- (UITableViewCell *)loadJoinGroupFlowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"JoinGroupFlowCell"];
    
    UILabel *tips1Label = (UILabel *)[cell.contentView viewWithTag:103];
    UILabel *tips2Label = (UILabel *)[cell.contentView viewWithTag:104];
    UILabel *tips3Label = (UILabel *)[cell.contentView viewWithTag:105];
    
    [tips1Label setPreferredMaxLayoutWidth:gAppMgr.deviceInfo.screenSize.width - 99];
    [tips2Label setPreferredMaxLayoutWidth:gAppMgr.deviceInfo.screenSize.width - 99];
    [tips3Label setPreferredMaxLayoutWidth:gAppMgr.deviceInfo.screenSize.width - 99];
    tips1Label.attributedText = [self generateAttributedStringWithLineSpacing:@"1、确认本团信息，选择车辆后即可入团。"];
    tips2Label.attributedText = [self generateAttributedStringWithLineSpacing:@"2、完善资料，填写信息后我们将对您的信息进行审核。"];
    tips3Label.attributedText = [self generateAttributedStringWithLineSpacing:@"3、选择购买的服务种类，方便我们为您精准报价。"];
    
    return cell;
}

- (NSAttributedString *)generateAttributedStringWithLineSpacing:(NSString *)string
{
    NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentJustified;
    style.lineSpacing = 4.0f;
    
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:string attributes:@{ NSParagraphStyleAttributeName : style}];
    
    return attrText;
}



@end
