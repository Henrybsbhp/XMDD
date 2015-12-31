//
//  CommissonOrderVC.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/17.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "CommissonOrderVC.h"
#import "NSString+RectSize.h"
#import "GetRescureDetailOp.h"
#import "CommissonConfirmVC.h"
#import "RescureHistoryViewController.h"
#import "LoginViewModel.h"
#import "GetStartHostCarOp.h"
#import "MyCarStore.h"
#import "EditCarVC.h"
#import "UIView+DefaultEmptyView.h"
#import "UIView+JTLoadingView.h"
#import "HKTableViewCell.h"
#import "WebVC.h"
#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
@interface CommissonOrderVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) MyCarStore    * carStore;
@property (nonatomic, strong) HKMyCar       * defaultCar;
@property (nonatomic, strong) NSArray       * carNumberArray;
@property (nonatomic, strong) UIImageView   * advertisingImg;
@property (nonatomic, strong) UIView        * footerView;
@property (nonatomic, strong) UIButton      * historyBtn;
@property (nonatomic, copy)   NSString      * testStr;
@property (nonatomic, strong) NSMutableArray * dataSourceArray;

@end

@implementation CommissonOrderVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"CommissonOrderVC dealloc!");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self actionNetwork];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.historyBtn];
}

#pragma mark - Action
- (IBAction)actionCommissionClick:(UIButton *)sender {
    [MobClick event:@"rp801-2"];
    
    if (gAppMgr.myUser != nil) {
        
        self.carStore = [MyCarStore fetchOrCreateStore];
        @weakify(self);
        [[[self.carStore getAllCars] send] subscribeNext:^(id x) {
            @strongify(self);
            if (self.carStore.cars.count == 0) {
                //TODO:1
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您还没有添加爱车, 请先添加爱车" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *n) {
                    NSInteger i = [n integerValue];
                    if (i == 1) {
                        EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
                        [self.navigationController pushViewController:vc animated:YES];
                    }else{
                    }
                }];
                [alert show];
            }
            else {
                //TODO: Request
                [self request];
            }
        }];
  
    }else{
        [MobClick event:@"rp101-2"];
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
            CommissonConfirmVC *vc = [commissionStoryboard instantiateViewControllerWithIdentifier:@"CommissonConfirmVC"];
            [self.navigationController pushViewController:vc animated:YES];
        
    }error:^(NSError *error) {
        if (error.code == 611139001) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您还没有协办券哦!\n点击省钱攻略,此等优惠岂能错过" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"省钱攻略", nil];
            [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *n) {
                NSInteger i = [n integerValue];
                if (i == 1) {
                    WebVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"WebVC"];
                    vc.title = @"省钱攻略";
                    vc.url = kMoneySavingStrategiesUrl;
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                    
                }
            }];
            [alert show];
        }
    }];
}


- (void) actionNetwork{
    GetRescureDetailOp *op = [GetRescureDetailOp operation];
    op.rescueid = 4;
    op.type = [NSNumber numberWithInteger:1];
    [[[[op rac_postRequest] initially:^{
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] finally:^{
        [self.view stopActivityAnimation];
    }] subscribeNext:^(GetRescureDetailOp *op) {
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
            [self.view showDefaultEmptyViewWithText:kDefErrorPormpt tapBlock:^{
                [self actionNetwork];
            }];
        }
    }] ;
    
}

- (void)commissionHistory {
    [MobClick event:@"rp801-1"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        RescureHistoryViewController *vc  =[rescueStoryboard instantiateViewControllerWithIdentifier:@"RescureHistoryViewController"];
        vc.type = 2;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HKTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RescureDetailsVC" forIndexPath:indexPath];
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
