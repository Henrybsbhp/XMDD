//
//  AreaTablePickerVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/4.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "AreaTablePickerVC.h"

typedef NS_ENUM(NSInteger, LocateState) {
    LocateStateLocating,    //定位中
    LocateStateSuccess,     //定位成功
    LocateStateFailure      //定位失败
};

@interface AreaTablePickerVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic)long long updateTime;

//页面类型(省市区)
@property (nonatomic, assign)AreaType areaType;
@property (nonatomic, strong)NSString * keyForUpdateTime;
@property (nonatomic, strong)NSString * keyForArea;

@property (nonatomic, strong)NSArray * dataSource;

//定位信息
@property (nonatomic, strong)HKLocationDataModel * locationData;
//定位状态
@property (nonatomic, assign)LocateState locateState;

@end

@implementation AreaTablePickerVC

+ (AreaTablePickerVC *)initPickerAreaVCWithType:(PickerVCType)pickerType fromVC:(UIViewController *)originvVC
{
    AreaTablePickerVC * vc = [UIStoryboard vcWithId:@"AreaTablePickerVC" inStoryboard:@"Common"];
    vc.pickerType = pickerType;
    vc.originVC = originvVC;
    vc.areaType = AreaTypeProvince;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择地区";
    
    self.tableView.hidden = YES;
    
    [self requestData];
    if (self.areaType == AreaTypeProvince) {
        [self requestLocation];
    }
}

#pragma mark - 获取定位信息
- (void)requestLocation
{
    self.locationData = [[HKLocationDataModel alloc] init];
    self.locateState = LocateStateLocating;
    @weakify(self);
    [[gMapHelper rac_getInvertGeoInfo] subscribeNext:^(id x) {
        
        @strongify(self);
        self.locationData.province = gMapHelper.addrComponent.province;
        self.locationData.city = gMapHelper.addrComponent.city;
        self.locationData.district = gMapHelper.addrComponent.district;
        self.locateState = LocateStateSuccess;
    } error:^(NSError *error) {
        
        @strongify(self);
        self.locateState = LocateStateFailure;
    }];
}

#pragma mark - 获取地理信息并存储到本地
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
        self.keyForUpdateTime = [NSString stringWithFormat:@"districtUpdateTime%ld", (long)self.areaId];
        self.keyForArea = [NSString stringWithFormat:@"districtFrom%ld", (long)self.areaId];
    }
    //将更新时间存到本地
    self.updateTime = [[[NSUserDefaults standardUserDefaults] objectForKey:self.keyForUpdateTime] longLongValue];
    
    GetAreaInfoOp * op = [GetAreaInfoOp operation];
    op.req_updateTime = self.updateTime;
    op.req_type = self.areaType;
    op.req_areaId = self.areaId;
    @weakify(self);
    [[op rac_postRequest] subscribeNext:^(GetAreaInfoOp * op) {
        
        @strongify(self);
        if (op.rsp_areaArray.count != 0) {
            
            //返回列表不为空
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@(op.rsp_maxTime) forKey:self.keyForUpdateTime];
            NSMutableArray * oldArray = [defaults objectForKey:self.keyForArea];
            if (oldArray.count == 0) {
                NSMutableArray * tempMuteArray = [NSMutableArray new];
                for (HKAreaInfoModel *areaModel in op.rsp_areaArray) {
                    NSData *areaEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:areaModel];
                    [tempMuteArray addObject:areaEncodedObject];
                }
                [defaults setObject:tempMuteArray forKey:self.keyForArea];
                self.dataSource = op.rsp_areaArray;
            }
            //增量更新本地数据
            else {
                [self updateAreaDataSource:op.rsp_areaArray forArray:oldArray];
            }
        }
        else {
            //返回列表为空，直接读取本地数据
            self.dataSource = [self getAreaFromUserDefaults];
        }
        [self.view stopActivityAnimation];
        self.tableView.hidden = NO;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        [gToast showError:@"获取地区列表失败，请检查网络连接"];
        @strongify(self);
        [self.view stopActivityAnimation];
    }];
}

#pragma mark - 增量更新地区信息
- (void)updateAreaDataSource:(NSMutableArray *)addArray forArray:(NSMutableArray *)oldArray
{
    for (int j =0; j < addArray.count; j++) {
        HKAreaInfoModel * newObj = addArray[j];
        for (int i =0; i < oldArray.count; i++) {
            HKAreaInfoModel *oldObj = oldArray[i];
            
            if (newObj.infoId == oldObj.infoId) {
                [oldArray replaceObjectAtIndex:i withObject:newObj];
                [addArray removeObjectAtIndex:j];
                j--;
            }
        }
        [oldArray addObject:newObj];
    }
}

- (void)bettwenMethod:(HKAreaInfoModel *)model fromArray:(NSMutableArray *)tempAreaArray
{
    
}

#pragma mark - 读取本地地区信息
- (NSMutableArray *)getAreaFromUserDefaults
{
    NSArray * userDefaultArr = [[NSArray alloc] init];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    userDefaultArr = [defaults objectForKey:self.keyForArea];
    
    NSMutableArray * tempMuteArray = [NSMutableArray new];
    for (NSData *areaData in userDefaultArr) {
        HKAreaInfoModel *areaObject = [NSKeyedUnarchiver unarchiveObjectWithData:areaData];
        [tempMuteArray addObject:areaObject];
    }
    return tempMuteArray;
}

#pragma mark - TabelViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.areaType == AreaTypeProvince) {
        return 2;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0 && self.areaType == AreaTypeProvince) {
        return @"定位到的位置";
    }
    return @"全部";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && self.areaType == AreaTypeProvince) {
        return 1;
    }
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && self.areaType == AreaTypeProvince) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeadCell" forIndexPath:indexPath];
        UILabel * label = (UILabel *)[cell.contentView viewWithTag:1001];
        UIActivityIndicatorView * activityView = (UIActivityIndicatorView *)[cell.contentView viewWithTag:1002];
        
        HKAreaInfoModel *areaObject = [self.dataSource safetyObjectAtIndex:indexPath.row];
        label.text = areaObject.infoName;
        
        @weakify(self);
        [[[RACObserve(self, locateState) distinctUntilChanged] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            @strongify(self);
            if (self.locateState == LocateStateLocating) {
                label.text = @"定位中...";
                activityView.hidden = NO;
                [activityView startAnimating];
            }
            else if (self.locateState == LocateStateSuccess) {
                [activityView stopAnimating];
                activityView.hidden = YES;
                if (self.pickerType == PickerVCTypeProvinceAndCity) {
                    label.text = [NSString stringWithFormat:@"%@ %@", self.locationData.province, self.locationData.city];
                }
                else {
                    label.text = [NSString stringWithFormat:@"%@ %@ %@", self.locationData.province, self.locationData.city, self.locationData.district];
                }
            }
            else {
                [activityView stopAnimating];
                activityView.hidden = YES;
                label.text = @"定位失败";
            }
        }];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LabelCell" forIndexPath:indexPath];
        UILabel * label = (UILabel *)[cell.contentView viewWithTag:1001];
        
        HKAreaInfoModel *areaObject = [self.dataSource safetyObjectAtIndex:indexPath.row];
        label.text = areaObject.infoName;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && self.areaType == AreaTypeProvince) {
        if (self.locateState == LocateStateFailure) {
            [self requestLocation];
        }
        else if (self.locateState == LocateStateSuccess) {
            getAreaByPcdOp * op = [getAreaByPcdOp operation];
            op.req_province = self.locationData.province;
            op.req_city = self.locationData.city;
            op.req_district = self.locationData.city;
            @weakify(self);
            [[op rac_postRequest] subscribeNext:^(getAreaByPcdOp * op) {
                
                @strongify(self);
                HKAreaInfoModel * provinceModel = op.rsp_city;
                HKAreaInfoModel * cityModel = op.rsp_city;
                HKAreaInfoModel * districtModel = op.rsp_city;
                if (self.selectCompleteAction) {
                    self.selectCompleteAction(provinceModel, cityModel, districtModel);
                }
            } error:^(NSError *error) {
                if (error.code == 6112001) {
                    [gToast showError:@"该地址无效，请手动选择"];
                }
                else {
                    [gToast showError:error.domain];
                }
            }];
        }
    }
    
    else {
        AreaTablePickerVC * vc = [UIStoryboard vcWithId:@"AreaTablePickerVC" inStoryboard:@"Common"];
        vc.pickerType = self.pickerType;
        vc.originVC = self.originVC;
        vc.selectCompleteAction = self.selectCompleteAction;
        
        HKAreaInfoModel *areaObject = [self.dataSource safetyObjectAtIndex:indexPath.row];
        vc.areaId = areaObject.infoId;
        if (self.areaType == AreaTypeProvince) {
            vc.areaType = AreaTypeCity;
            self.selectedArray = [[NSMutableArray alloc] init];
            [self.selectedArray addObject:areaObject];
            vc.selectedArray = self.selectedArray;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (self.areaType == AreaTypeCity) {
            if (self.pickerType == PickerVCTypeProvinceAndCity) {
                HKAreaInfoModel * provinceModel = [self.selectedArray safetyObjectAtIndex:0];
                HKAreaInfoModel * cityModel = areaObject;
                
                if (self.selectCompleteAction) {
                    self.selectCompleteAction(provinceModel, cityModel, nil);
                }
                
                if (self.originVC) {
                    [self.navigationController popToViewController:self.originVC animated:YES];
                }
                else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            else {
                vc.areaType = AreaTypeDicstrict;
                [self.selectedArray addObject:areaObject];
                vc.selectedArray = self.selectedArray;
                
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        else {
            HKAreaInfoModel * provinceModel = [self.selectedArray safetyObjectAtIndex:0];
            HKAreaInfoModel * cityModel = [self.selectedArray safetyObjectAtIndex:1];
            HKAreaInfoModel * districtModel = areaObject;
            
            if (self.selectCompleteAction) {
                self.selectCompleteAction(provinceModel, cityModel, districtModel);
            }
            
            if (self.originVC) {
                [self.navigationController popToViewController:self.originVC animated:YES];
            }
            else {
                [self.navigationController popViewControllerAnimated:YES];
            }
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
