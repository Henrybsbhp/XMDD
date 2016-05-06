//
//  MutualInsClaimsHistoryVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/3.
//  Copyright © 2016年 huika. All rights reserved.
//
#import "HKInclinedLabel.h"
#import "MutualInsClaimsHistoryVC.h"
#import "GetCooperationClaimsListOp.h"
#import "MutualInsClaimInfo.h"
#import "MutualInsClaimDetailVC.h"
#import "NSString+Price.h"
#import "NSDate+DateForText.h"
#import "HKImageAlertVC.h"

@interface MutualInsClaimsHistoryVC ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *dataArr;
@property (strong, nonatomic) HKImageAlertVC *alert;
@end

@implementation MutualInsClaimsHistoryVC

-(void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"MutualInsClaimsHistoryVC dealloc");
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    
    @weakify(self)
    [[self.tableView.refreshView rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        @strongify(self);
        [self loadData];
    }];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(setBackAction)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArr.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MutualInsClaimInfo *model = [self.dataArr safetyObjectAtIndex:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [self addCorner:cell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    HKInclinedLabel *hkLabel = [cell viewWithTag:101];
    hkLabel.text = model.statusdesc;
    NSLog(@"%lf",hkLabel.frame.size.width);
    hkLabel.backgroundColor = [UIColor clearColor];
    UILabel *statusLabel = [cell viewWithTag:1004];
    statusLabel.text = model.detailstatusdesc;
    if (model.detailstatus < 3)
    {
        hkLabel.trapeziumColor = HEXCOLOR(@"#ff7428");
        statusLabel.textColor = HEXCOLOR(@"#ff7428");
    }
    else
    {
        hkLabel.trapeziumColor = HEXCOLOR(@"#18D06A");
        statusLabel.textColor = HEXCOLOR(@"#18D06A");
    }
    hkLabel.textColor = [UIColor whiteColor];
    
    UIView *backView = [cell viewWithTag:1000];
    [self addCorner:backView];
    
    UILabel *plateNum = [cell viewWithTag:1001];
    plateNum.text = model.licensenum;
    
    UILabel *detaiLabel = [cell viewWithTag:1002];
    detaiLabel.preferredMaxLayoutWidth = cell.bounds.size.width - 35;
    detaiLabel.text = [NSString stringWithFormat:@"事故经过：%@",model.accidentdesc];
    UILabel *priceLabel = [cell viewWithTag:1003];
    priceLabel.text = model.claimfee > 0 ? [NSString formatForPriceWithFloatWithDecimal:model.claimfee] : @"待估价";
    
    UILabel *titleLb = [cell viewWithTag:109];
    titleLb.text = model.claimfee > 0 ? @"费用":@"";
    
    
    
    UILabel *timeLabel = [cell viewWithTag:1005];
    timeLabel.text = [NSString stringWithFormat:@"%@",model.lstupdatetime];
    
    return cell;
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0018"}];
    MutualInsClaimInfo *model = [self.dataArr safetyObjectAtIndex:indexPath.section];
    MutualInsClaimDetailVC *detailVC = [[UIStoryboard storyboardWithName:@"MutualInsClaims" bundle:nil]instantiateViewControllerWithIdentifier:@"MutualInsClaimDetailVC"];
    detailVC.claimid = model.claimid;
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 15;
    }
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 180;
}

#pragma mark Utility

-(void)addCorner:(UIView *)view
{
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
}

-(void)loadData
{
    if(![LoginViewModel loginIfNeededForTargetViewController:self])
    {
        return;
    }
    else
    {
        GetCooperationClaimsListOp *op = [GetCooperationClaimsListOp new];
        @weakify(self)
        [[[[op rac_postRequest] initially:^{
            @strongify(self)
            [self.view hideDefaultEmptyView];
            if (!self.dataArr.count)
            {
                [self.view startActivityAnimationWithType:GifActivityIndicatorType];
            }
        }] finally:^{
            @strongify(self)
            [self.view stopActivityAnimation];
            [self.tableView.refreshView endRefreshing];
        }] subscribeNext:^(id x) {
            @strongify(self)
            [self.view stopActivityAnimation];
            
            self.dataArr = op.rsp_claimlist;
            if (self.dataArr.count == 0)
            {
                
                [self.view showImageEmptyViewWithImageName:@"def_withClaimHistory" text:@"您还没有补偿记录" tapBlock:^{
                    @strongify(self)
                    [self loadData];
                }];
            }
            [self.tableView reloadData];
        }error:^(NSError *error) {
            @strongify(self)
            [self.view stopActivityAnimation];
            [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"获取补偿记录失败,点击重新获取" tapBlock:^{
                @strongify(self)
                [self loadData];
            }];
        }];
    }
}


#pragma mark Action

-(void)setBackAction
{
    [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0017"}];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)callAction:(id)sender {
    [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0016"}];
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
        [gPhoneHelper makePhone:@"4007111111"];
    }];
    HKAlertVC *alert = [self alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"如有任何疑问，可拨打客服电话：4007-111-111" ActionItems:@[cancel,confirm]];
    [alert show];
}

#pragma mark LazyLoad
-(NSArray *)dataArr
{
    if (!_dataArr)
    {
        _dataArr = [[NSArray alloc]init];
    }
    return _dataArr;
}

-(HKImageAlertVC *)alertWithTopTitle:(NSString *)topTitle ImageName:(NSString *)imageName Message:(NSString *)message ActionItems:(NSArray *)actionItems
{
    if (!_alert)
    {
        _alert = [[HKImageAlertVC alloc]init];
    }
    _alert.topTitle = topTitle;
    _alert.imageName = imageName;
    _alert.message = message;
    _alert.actionItems = actionItems;
    return _alert;
}

@end
