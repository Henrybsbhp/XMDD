//
//  AreaTablePickerVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/4.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "AreaTablePickerVC.h"

@interface AreaTablePickerVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic)long long updateTime;

@property (nonatomic, strong)NSString * keyForUpdateTime;
@property (nonatomic, strong)NSString * keyForArea;

@property (nonatomic, strong)NSArray * dataSource;

@end

@implementation AreaTablePickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择地区";
    
    self.tableView.hidden = YES;
    [self requestData];
}

- (void)requestData
{
    [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    
    
    if (self.areaType == AreaTypeProvince) {
        self.keyForUpdateTime = @"provinceUpdateTime";
        self.keyForArea = @"provinceArray";
    }
    else if (self.areaType == AreaTypeCity) {
        self.keyForUpdateTime = [NSString stringWithFormat:@"cityUpdateTime%ld", (long)self.areaId];
        self.keyForArea = [NSString stringWithFormat:@"cityFrom%ld", (long)self.areaId];
    }
    else {
        self.keyForUpdateTime = [NSString stringWithFormat:@"disctrictUpdateTime%ld", (long)self.areaId];
        self.keyForArea = [NSString stringWithFormat:@"disctrictFrom%ld", (long)self.areaId];
    }
    self.updateTime = [[[NSUserDefaults standardUserDefaults] objectForKey:self.keyForUpdateTime] longLongValue];
    
    
    GetAreaInfoOp * op = [GetAreaInfoOp operation];
    op.req_updateTime = self.updateTime;
    op.req_type = self.areaType;
    op.req_areaId = self.areaId;
    @weakify(self);
    [[op rac_postRequest] subscribeNext:^(GetAreaInfoOp * op) {
        
        @strongify(self);
        if (op.rsp_areaArray.count != 0) {
            self.dataSource = op.rsp_areaArray;
            
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@(op.rsp_maxTime) forKey:self.keyForUpdateTime];
            
            NSMutableArray * tempMuteArray = [NSMutableArray new];
            for (HKAreaInfoModel *areaModel in op.rsp_areaArray) {
                NSData *areaEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:areaModel];
                [tempMuteArray addObject:areaEncodedObject];
            }
            [defaults setObject:tempMuteArray forKey:self.keyForArea];
        }
        else {
            NSArray * userDefaultArr = [[NSArray alloc] init];
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            userDefaultArr = [defaults objectForKey:self.keyForArea];
            
            NSMutableArray * tempMuteArray = [NSMutableArray new];
            for (NSData *areaData in userDefaultArr) {
                HKAreaInfoModel *areaObject = [NSKeyedUnarchiver unarchiveObjectWithData:areaData];
                [tempMuteArray addObject:areaObject];
            }
            self.dataSource = tempMuteArray;
        }
        [self.view stopActivityAnimation];
        self.tableView.hidden = NO;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        @strongify(self);
        [self.view stopActivityAnimation];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LabelCell" forIndexPath:indexPath];
    UILabel * label = (UILabel *)[cell.contentView viewWithTag:1001];
    
    HKAreaInfoModel *areaObject = [self.dataSource safetyObjectAtIndex:indexPath.row];
    label.text = areaObject.infoName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AreaTablePickerVC * vc = [UIStoryboard vcWithId:@"AreaTablePickerVC" inStoryboard:@"Common"];
    vc.originVC = self.originVC;
    HKAreaInfoModel *areaObject = [self.dataSource safetyObjectAtIndex:indexPath.row];
    vc.areaId = areaObject.infoId;
    if (self.areaType == AreaTypeProvince) {
        vc.areaType = AreaTypeCity;
        vc.originVC = self.originVC;
        self.selectedArray = [[NSMutableArray alloc] init];
        [self.selectedArray addObject:areaObject];
        vc.selectedArray = self.selectedArray;
        
        [vc setSelectCompleteAction:^(HKAreaInfoModel * provinceModel, HKAreaInfoModel * cityModel, HKAreaInfoModel * disctrictModel) {
            if (self.selectCompleteAction) {
                self.selectCompleteAction(provinceModel, cityModel, disctrictModel);
            }
        }];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (self.areaType == AreaTypeCity) {
        
        vc.areaType = AreaTypeDicstrict;
        [self.selectedArray addObject:areaObject];
        vc.selectedArray = self.selectedArray;
        
        [vc setSelectCompleteAction:^(HKAreaInfoModel * provinceModel, HKAreaInfoModel * cityModel, HKAreaInfoModel * disctrictModel) {
            if (self.selectCompleteAction) {
                self.selectCompleteAction(provinceModel, cityModel, disctrictModel);
            }
        }];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        HKAreaInfoModel * provinceModel = [self.selectedArray safetyObjectAtIndex:0];
        HKAreaInfoModel * cityModel = [self.selectedArray safetyObjectAtIndex:1];
        HKAreaInfoModel * disctrictModel = areaObject;
        
        if (self.selectCompleteAction) {
            self.selectCompleteAction(provinceModel, cityModel, disctrictModel);
        }
        
        if (self.originVC) {
            [self.navigationController popToViewController:self.originVC animated:YES];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)dealloc {
    DebugLog(@"dealloc~~~");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
