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
    NSString * deallocInfo = [NSString stringWithFormat:@"%@ dealloc~~",NSStringFromClass([self class])];
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(deallocInfo);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self network];
    self.tableView.separatorStyle = NO;
    CKAsyncMainQueue(^{
        self.loadingModel = [[HKLoadingModel alloc] initWithTargetView:self.tableView delegate:self];
        //[self.loadingModel loadDataForTheFirstTime];
    });
}
- (void)network {
    GetRescueHistoryOp *op = [GetRescueHistoryOp operation];
    op.applytime = self.applyTime;
    op.type = 1;
    @weakify(self)
    [[[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"加载中..."];
        
    }] finally:^{
        
        
    }] subscribeNext:^(GetRescueHistoryOp *op) {
        @strongify(self)
        
        self.dataSourceArray = (NSMutableArray *)op.req_applysecueArray;
        NSLog(@"%@", self.dataSourceArray);
        [gToast dismiss];
        
        [self.tableView reloadData];
        
    } error:^(NSError *error) {
        
        NSLog(@"%@", error.description);
    }] ;
    

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RescureHistoryViewController" forIndexPath:indexPath];
    HKRescueHistory *hostory = self.dataSourceArray[indexPath.row];
    UILabel *plateLb = [cell.contentView viewWithTag:1000];
    UILabel *evaluationLb = [cell.contentView viewWithTag:1001];
    UILabel *stateLb = [cell.contentView viewWithTag:1002];
    UILabel *timeLb = [cell.contentView viewWithTag:1003];
    UILabel *titleLb = [cell.contentView viewWithTag:1004];
    UIImageView *image = [cell.contentView viewWithTag:1005];
    evaluationLb.layer.borderWidth = 1;
    evaluationLb.layer.borderColor = [UIColor colorWithHex:@"#fe4a00" alpha:1].CGColor;
    evaluationLb.layer.cornerRadius = 4;
    evaluationLb.layer.masksToBounds = YES;
    plateLb.text = [NSString stringWithFormat:@"服务车辆: %@", hostory.licenceNumber];
    if ([hostory.commentStatus integerValue] == 0) {
        evaluationLb.text = @"未评价";
    }else if ([hostory.commentStatus integerValue]== 1){
        evaluationLb.text = @"已评价";
    }
    if ([hostory.rescueStatus integerValue] == 2) {
        stateLb.text = @"已申请";
        evaluationLb.hidden = YES;
    }else{
        stateLb.text = @"已完成";
    }
    NSLog(@"%@", hostory.type);
    if ([hostory.type integerValue] == 1) {
        image.image = [UIImage imageNamed:@"拖车服务"];
    }else if ([hostory.type integerValue] == 2){
        image.image = [UIImage imageNamed:@"泵电服务"];
    }else {
        image.image = [UIImage imageNamed:@"换胎服务"];
    }
    
    titleLb.text = hostory.serviceName;
    NSString *timeStr = [NSString stringWithFormat:@"%@", hostory.applyTime];
    NSString *tempStr = [timeStr substringToIndex:10];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[tempStr intValue]];
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    timeLb.text = [dateFormat stringFromDate:confromTimesp];
    
    if (titleLb.text) {
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", indexPath);
     HKRescueHistory *hostory = self.dataSourceArray[indexPath.row];
    [MobClick event:@"rp101-5"];
    RescurecCommentsVC *vc = [UIStoryboard vcWithId:@"RescurecCommentsVC" inStoryboard:@"Rescue"];
    vc.applyTime = hostory.applyTime;
    vc.isLog = [hostory.commentStatus integerValue];
    vc.type = [hostory.type integerValue];
    vc.serviceName = hostory.serviceName;
    vc.applyId = hostory.applyId;
    vc.licenceNumber = hostory.licenceNumber;
    if ([hostory.rescueStatus integerValue] != 2) {
    [self.navigationController pushViewController:vc animated:YES];
    }
   
    
}
#pragma mark - lazy
- (NSMutableArray *)dataSourceArray {
    if (!_dataSourceArray) {
        self.dataSourceArray = [@[] mutableCopy];
    }
    return _dataSourceArray;
}

#pragma mark - HKLoadingModelDelegate
- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKLoadingTypeMask)type
{
    return @"暂无救援历史";
}

- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKLoadingTypeMask)type error:(NSError *)error
{
    return @"获取失败，点击重试";
}

@end
