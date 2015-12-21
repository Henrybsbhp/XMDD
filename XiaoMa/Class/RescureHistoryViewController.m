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
@interface RescureHistoryViewController ()<UITableViewDelegate, UITableViewDataSource, HKLoadingModelDelegate>

@property (nonatomic, strong) HKLoadingModel *loadingModel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self historyNetwork];
}

#pragma mark - network
- (void)historyNetwork {
    GetRescueHistoryOp *op = [GetRescueHistoryOp operation];
    op.applytime = self.applyTime;
    op.type = self.type;
    @weakify(self)
    [[[[op rac_postRequest] initially:^{
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] finally:^{
        [self.view stopActivityAnimation];
    }] subscribeNext:^(GetRescueHistoryOp *op) {
        @strongify(self)
        
        self.dataSourceArray = (NSMutableArray *)op.req_applysecueArray;
        if (self.dataSourceArray.count == 0) {
            [self.view showDefaultEmptyViewWithText:@"暂无历史记录"];
        }
        [self.tableView reloadData];
    } error:^(NSError *error) {
        @strongify(self);
        [self.view stopActivityAnimation];
        [self.view showDefaultEmptyViewWithText:kDefErrorPormpt tapBlock:^{
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
        NSLog(@"------%ld", [hostory.commentStatus integerValue])
        ;    }else if ([hostory.commentStatus integerValue]== 1){
            
            
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
    }else{
        stateLb.text = @"已完成";
    }
    NSLog(@"%@", hostory.type);
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
    
    
    
    [[[button rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        if ([hostory.rescueStatus integerValue] != 2) {
            RescurecCommentsVC *vc = [UIStoryboard vcWithId:@"RescurecCommentsVC" inStoryboard:@"Rescue"];
            vc.applyTime = hostory.applyTime;
            vc.isLog = [hostory.commentStatus integerValue];
            vc.type = [hostory.type integerValue];
            vc.serviceName = hostory.serviceName;
            vc.applyId = hostory.applyId;
            vc.applyType = [NSNumber numberWithInteger:self.type];
            vc.licenceNumber = hostory.licenceNumber;
            vc.applyType = [NSNumber numberWithInteger:self.type];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        
    }];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HKRescueHistory *hostory = [self.dataSourceArray safetyObjectAtIndex:indexPath.row];
    if ([hostory.rescueStatus integerValue] != 2) {
        RescurecCommentsVC *vc = [UIStoryboard vcWithId:@"RescurecCommentsVC" inStoryboard:@"Rescue"];
        vc.applyTime = hostory.applyTime;
        vc.isLog = [hostory.commentStatus integerValue];
        vc.type = [hostory.type integerValue];
        vc.serviceName = hostory.serviceName;
        vc.applyId = hostory.applyId;
        vc.applyType = [NSNumber numberWithInteger:1];
        vc.licenceNumber = hostory.licenceNumber;
        vc.applyType = [NSNumber numberWithInteger:self.type];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - lazy
- (NSMutableArray *)dataSourceArray {
    if (!_dataSourceArray) {
        self.dataSourceArray = [[NSMutableArray alloc] init];
    }
    return _dataSourceArray;
}

@end
