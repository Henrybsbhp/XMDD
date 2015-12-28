//
//  RescureHistoryViewController.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/10.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "RescureHistoryViewController.h"
#import "RescurecCommentsVC.h"
#import "GetRescueHistoryOp.h"
#import "HKRescueHistory.h"
#import "HKLoadingModel.h"
#import "UIView+DefaultEmptyView.h"
#import "UIView+JTLoadingView.h"
#import "rescueCancelHostcar.h"
@interface RescureHistoryViewController ()<UITableViewDelegate, UITableViewDataSource, HKLoadingModelDelegate>

@property (weak, nonatomic) IBOutlet JTTableView *tableView;
@property (nonatomic, strong) HKLoadingModel *loadingModel;
//@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataSourceArray;
@property (nonatomic, assign) long long applyTime;
@property (nonatomic, assign) NSInteger applyType;
@end

@implementation RescureHistoryViewController

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"RescureHistoryViewController dealloc");
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self historyNetwork];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.type == 1) {
        self.navigationItem.title = @"救援记录";
    }else {
        self.navigationItem.title = @"协办记录";
    }
}

#pragma mark - network
- (void)historyNetwork {
    GetRescueHistoryOp *op = [GetRescueHistoryOp operation];
    op.applytime = self.applyTime;
    op.type = self.type;
    [[[[op rac_postRequest] initially:^{
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] finally:^{
        [self.view stopActivityAnimation];
    }] subscribeNext:^(GetRescueHistoryOp *op) {
        self.dataSourceArray = (NSMutableArray *)op.req_applysecueArray;
        if (self.dataSourceArray.count == 0) {
            if (self.type == 1) {
                [self.view showDefaultEmptyViewWithText:@"暂无救援记录"];
            }else {
                [self.view showDefaultEmptyViewWithText:@"暂无协办记录"];
            }
        }
        
        [self.tableView reloadData];
    } error:^(NSError *error) {
        [gToast showDefaultEmptyViewWithText:kDefErrorPormpt tapBlock:^{
            [self historyNetwork];
        }];
    }] ;
    
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RescureHistoryViewController" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    HKRescueHistory *hostory = self.dataSourceArray[indexPath.row];
    UILabel *plateLb = (UILabel *)[cell searchViewWithTag:1000];
    UILabel *evaluationLb = (UILabel *)[cell searchViewWithTag:1001];
    UILabel *stateLb = (UILabel *)[cell searchViewWithTag:1002];
    UILabel *timeLb = (UILabel *)[cell searchViewWithTag:1003];
    UILabel *titleLb = (UILabel *)[cell searchViewWithTag:1004];
    UIImageView *image = (UIImageView *)[cell searchViewWithTag:1005];
    UIButton *button = (UIButton *)[cell searchViewWithTag:1007];
    button.tag = indexPath.row;
    evaluationLb.layer.borderWidth = 1;
    evaluationLb.layer.borderColor = [UIColor colorWithHex:@"#fe4a00" alpha:1].CGColor;
    evaluationLb.layer.cornerRadius = 4;
    evaluationLb.layer.masksToBounds = YES;
    plateLb.text = [NSString stringWithFormat:@"服务车辆: %@", hostory.licenceNumber];
    if ([hostory.commentStatus integerValue] == 0) {
        evaluationLb.text = @"未评价";
        if ([hostory.rescueStatus integerValue] == 4 || [hostory.rescueStatus integerValue] == 5) {
            evaluationLb.hidden = YES;
        }
    }else if ([hostory.commentStatus integerValue]== 1){
        evaluationLb.text = @"已评价";
    }
    
    if ([hostory.rescueStatus integerValue] == 2) {
        stateLb.text = @"已申请";
        evaluationLb.hidden = YES;
        if (self.type == 2) {
            evaluationLb.hidden  = NO;
            evaluationLb.layer.borderColor = [UIColor colorWithHex:@"#bfbfbf" alpha:1].CGColor;
            evaluationLb.textColor = [UIColor colorWithHex:@"#bfbfbf" alpha:1];
            evaluationLb.text = @"取消";
        }
    }else if ([hostory.rescueStatus integerValue] == 3){
        evaluationLb.hidden = NO;
        stateLb.text = @"已完成";
    }else if ([hostory.rescueStatus integerValue] == 4){
        stateLb.text = @"已取消";
        button.hidden = YES;
    }else if ([hostory.rescueStatus integerValue] == 5){
        button.hidden = YES;
        stateLb.text = @"处理中";
    }
    if (self.type == 2) {
        image.image = [UIImage imageNamed:@"commission_annual"];
    }else if ([hostory.type integerValue] == 1) {
        image.image = [UIImage imageNamed:@"rescue_trailer"];
    }else if ([hostory.type integerValue] == 2){
        image.image = [UIImage imageNamed:@"pump_power"];
    }else {
        image.image = [UIImage imageNamed:@"rescue_tire"];
    }
    
    titleLb.text = hostory.serviceName;
    NSString *timeStr = [NSString stringWithFormat:@"%@", hostory.applyTime];
    NSString *tempStr = [timeStr substringToIndex:10];
    timeLb.text = [[NSDate dateWithTimeIntervalSince1970:[tempStr intValue]] dateFormatForYYYYMMddHHmm2];
    
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        HKRescueHistory *hostory = self.dataSourceArray[indexPath.row];
        if ([hostory.rescueStatus integerValue] != 2 && [hostory.rescueStatus integerValue] != 4 && [hostory.rescueStatus integerValue] != 5) {
            
            RescurecCommentsVC *vc = [UIStoryboard vcWithId:@"RescurecCommentsVC" inStoryboard:@"Rescue"];
            vc.applyTime = hostory.applyTime;
            
            [RACObserve(hostory,commentStatus) subscribeNext:^(NSNumber *num) {
                vc.isLog = [num integerValue];
            }];
            vc.type = [hostory.type integerValue];
            vc.serviceName = hostory.serviceName;
            vc.applyId = hostory.applyId;
            if ([hostory.type integerValue] == 0) {
                vc.applyType = [NSNumber numberWithInteger:2];
            }else {
                vc.applyType = [NSNumber numberWithInteger:1];
            }
            vc.licenceNumber = hostory.licenceNumber;
            /**
             *  救援评价事件
             */
            if (self.type == 1)
            {
                if (hostory.commentStatus == 0)
                {
                    [MobClick event:@"rp705-1"];
                }
                else
                {
                    [MobClick event:@"rp705-2"];
                }
            }
            else
            {
                if (hostory.commentStatus == 0)
                {
                    [MobClick event:@"rp804-2"];
                }
                else
                {
                    [MobClick event:@"rp804-3"];
                }
            }
            [self.navigationController pushViewController:vc animated:YES];
        }else if ([hostory.rescueStatus integerValue] == 2 && self.type == 2){
            /**
             *  取消按钮点击事件
             */
            [MobClick event:@"rp804-1"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您确定要本次协办服务吗？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
            [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *n) {
                
                NSInteger i = [n integerValue];
                if (i == 1)
                {
                    rescueCancelHostcar *op = [rescueCancelHostcar operation];
                    op.applyId = hostory.applyId;
                    [[[[op rac_postRequest] initially:^{
                        [gToast showText:@"取消中..."];
                    }] finally:^{
                        [gToast dismiss];
                    }] subscribeNext:^(rescueCancelHostcar *op) {
                        if (op.rsp_code == 0) {
                            [gToast showText:@"取消成功"];
                            [self historyNetwork];
                        }
                        
                    } error:^(NSError *error) {
                        [gToast showText:@"取消失败, 请重试"];
                    }] ;
                }
                
            }];
            
            
        }
        
        
    }];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark - lazy
- (NSMutableArray *)dataSourceArray {
    if (!_dataSourceArray) {
        self.dataSourceArray = [[NSMutableArray alloc] init];
    }
    return _dataSourceArray;
}
/*
 - (void)searchMoreShops
 {
 if ([self.tableView.bottomLoadingView isActivityAnimating])
 {
 return;
 }
 
 NSString * searchInfo = self.searchBar.text;
 searchInfo = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
 GetShopByNameV2Op * op = [GetShopByNameV2Op operation];
 op.longitude = self.coordinate.longitude;
 op.latitude = self.coordinate.latitude;
 op.shopName = searchInfo;
 op.pageno = self.currentPageIndex;
 op.orderby = 1;
 
 [[[op rac_postRequest] initially:^{
 
 [self.tableView.bottomLoadingView hideIndicatorText];
 [self.tableView.bottomLoadingView startActivityAnimationWithType:MONActivityIndicatorType];
 self.isLoading = YES;
 }] subscribeNext:^(GetShopByNameV2Op * op) {
 
 self.currentPageIndex = self.currentPageIndex + 1;
 [self.tableView.bottomLoadingView stopActivityAnimation];
 self.isLoading = NO;
 if(op.rsp_code == 0)
 {
 [self.tableView hideDefaultEmptyView];
 if (op.rsp_shopArray.count >= self.pageAmount)
 {
 self.isRemain = YES;
 }
 else
 {
 self.isRemain = NO;
 }
 if (!self.isRemain)
 {
 self.tableView.showBottomLoadingView = YES;
 [self.tableView.bottomLoadingView showIndicatorTextWith:@"已经到底了"];
 }
 
 NSMutableArray * tArray = [NSMutableArray arrayWithArray:self.resultArray];
 [tArray addObjectsFromArray:op.rsp_shopArray];
 self.resultArray = [NSArray arrayWithArray:tArray];
 [self.tableView reloadData];
 }
 else
 {
 [self.tableView.bottomLoadingView showIndicatorTextWith:@"获取失败，再拉拉看"];
 }
 } error:^(NSError *error) {
 self.isLoading = NO;
 self.tableView.showBottomLoadingView = YES;
 [self.tableView.bottomLoadingView stopActivityAnimation];
 [self.tableView.bottomLoadingView showIndicatorTextWith:@"获取失败，再拉拉看"];
 
 }];
 }
 */
@end
