//
//  CommissionOrderVC.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/17.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "CommissionOrderVC.h"
#import "NSString+RectSize.h"
#import "GetRescueDetailOp.h"
#import "CommissionConfirmVC.h"
#import "RescueHistoryViewController.h"
#import "LoginViewModel.h"
#import "GetStartHostCarOp.h"
#import "MyCarStore.h"
#import "EditCarVC.h"
#import "UIView+DefaultEmptyView.h"
#import "UIView+JTLoadingView.h"
#import "HKTableViewCell.h"
#import "DetailWebVC.h"
#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
@interface CommissionOrderVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) MyCarStore    * carStore;
@property (nonatomic, strong) HKMyCar       * defaultCar;
@property (nonatomic, strong) NSArray       * carNumberArray;
@property (nonatomic, strong) UIImageView   * advertisingImg;
@property (nonatomic, strong) UIView        * footerView;
@property (nonatomic, strong) UIButton      * historyBtn;
@property (nonatomic, strong) NSMutableArray * dataSourceArray;
@end

@implementation CommissionOrderVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"CommissionOrderVC dealloc!");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self actionNetwork];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.historyBtn];
}


#pragma mark - Action
- (IBAction)actionCommissionClick:(UIButton *)sender {
    [MobClick event:@"rp801_2"];
    if (gAppMgr.myUser != nil) {
        self.carStore = [MyCarStore fetchOrCreateStore];
        @weakify(self);
        [[[[self.carStore getAllCars] send] initially:^{
          
            [gToast showingWithText:@"" inView:self.view];
        }] subscribeNext:^(id x) {
            
            [gToast dismissInView:self.view];
            @strongify(self);
            if (self.carStore.cars.count == 0) {
                //TODO:1
                
                HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
                HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"省钱攻略" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                    EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
                    [self.navigationController pushViewController:vc animated:YES];
                }];
                HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"添加爱车" ImageName:@"mins_bulb" Message:@"您还没有添加爱车, 请先添加爱车" ActionItems:@[cancel,confirm]];
                [alert show];
            }
            else {
                //TODO: Request
                [self request];
            }
        }error:^(NSError *error) {
            
            [gToast dismissInView:self.view];
            NSString * number = @"4007111111";
            [gPhoneHelper makePhone:number andInfo:@"协办电话: 4007-111-111"];
        }];
        
    }else{
        NSString * number = @"4007111111";
        [gPhoneHelper makePhone:number andInfo:@"协办电话: 4007-111-111"];
    }
}

- (void)request
{
    GetStartHostCarOp *op = [GetStartHostCarOp operation];
    [[[op rac_postRequest] initially:^{
        
    }] subscribeNext:^(GetStartHostCarOp *rspop) {
        
        self.carNumberArray = self.carStore.allCars;
        CommissionConfirmVC *vc = [commissionStoryboard instantiateViewControllerWithIdentifier:@"CommissonConfirmVC"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }error:^(NSError *error) {
        if (error.code == 611139001) {
            
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
            HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"省钱攻略" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
                vc.title = @"省钱攻略";
                vc.url = kMoneySavingStrategiesUrl;
                [self.navigationController pushViewController:vc animated:YES];
            }];
            HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"亲,暂时只支持协办券办理哦!\n点击省钱攻略免费获取协办券!" ActionItems:@[cancel,confirm]];
            [alert show];
        }
    }];
}


- (void) actionNetwork{
    GetRescueDetailOp *op = [GetRescueDetailOp operation];
    op.rescueid = 4;
    op.type = [NSNumber numberWithInteger:1];
    [[[[op rac_postRequest] initially:^{
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] finally:^{
        [self.view stopActivityAnimation];
    }] subscribeNext:^(GetRescueDetailOp *op) {
        [self.dataSourceArray removeAllObjects];
        NSString *lastStr;
        for (NSString *testStr in op.rescueDetailArray) {
            lastStr = [testStr stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
            [self.dataSourceArray safetyAddObject:lastStr];
        }
        
        NSString *string = [NSString stringWithFormat:@"● %@", [self.dataSourceArray safetyObjectAtIndex:0]];
        [self.dataSourceArray safetyReplaceObjectAtIndex:0 withObject:string];
        self.tableView.tableHeaderView = self.advertisingImg;
        self.tableView.tableFooterView = self.footerView;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        if (self.dataSourceArray.count == 0) {
            [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:kDefErrorPormpt tapBlock:^{
                [self actionNetwork];
            }];
        }
    }] ;
    
}

- (void)commissionHistory {
    [MobClick event:@"rp801_1"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        RescueHistoryViewController *vc  =[rescueStoryboard instantiateViewControllerWithIdentifier:@"RescueHistoryViewController"];
        vc.type = 2;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HKTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommissionOrderVC" forIndexPath:indexPath];
    if (indexPath.row != 0) {
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalTop insets:UIEdgeInsetsMake(- 1, 0, 0, 0)];
    }
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 0, 7, 0)];
    if (indexPath.row == self.dataSourceArray.count - 1) {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    UILabel * titleLb  = (UILabel *)[cell searchViewWithTag:1000];
    UILabel * detailLb = (UILabel *)[cell searchViewWithTag:1001];
    UIView  * topView  = (UIView *) [cell searchViewWithTag:1004];
    UIView  * lineView = (UIView *) [cell searchViewWithTag:1005];
    if (indexPath.row == 0) {
        topView.hidden = YES;
    }else if (indexPath.row == 2) {
        lineView.hidden = YES;
    }
    NSString * string = [self.dataSourceArray safetyObjectAtIndex:indexPath.row];
    detailLb.text = string;
    //行间距
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:4];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [string length])];
    [detailLb setAttributedText:attributedString1];
    if (indexPath.row == 0) {
        titleLb.text = @"服务对象";
    }else if (indexPath.row == 1){
        titleLb.text = @"准备材料";
    }else if (indexPath.row == 2){
        titleLb.text = @"注意事项";
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * str = [self.dataSourceArray safetyObjectAtIndex:indexPath.row];
    
    CGFloat width = kWidth - 30;
    CGSize size = [str labelSizeWithWidth:width font:[UIFont systemFontOfSize:12]];
    CGFloat height;
    height = size.height + 63;
    if (size.height > 40) {
        height = size.height + 80;
    }
    return height;
}

#pragma mark - lazyLoading

- (UIImageView *)advertisingImg {
    if (!_advertisingImg) {
        self.advertisingImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 0.44 * kWidth)];
        _advertisingImg.image = [UIImage imageNamed:@"commissonBanner"];
    }
    return _advertisingImg;
}
- (UIView *)footerView {
    if (!_footerView) {
        self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, (kWidth- 20) * 0.13 + 7)];
    }
    return _footerView;
}
- (NSMutableArray *)dataSourceArray{
    if (!_dataSourceArray) {
        self.dataSourceArray = [[NSMutableArray alloc] init];
    }
    return _dataSourceArray;
}

- (UIButton *)historyBtn {
    if (!_historyBtn) {
        self.historyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _historyBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _historyBtn.frame = CGRectMake(0, 0, 60, 44);
        [_historyBtn setTitle:@"协办记录" forState:UIControlStateNormal];
        [_historyBtn addTarget:self action:@selector(commissionHistory) forControlEvents:UIControlEventTouchUpInside];
    }
    return _historyBtn;
}

@end
