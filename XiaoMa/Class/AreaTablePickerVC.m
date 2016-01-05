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

- (void)dealloc {
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"AreaTablePickerVC dealloc~~~");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    
    [self setKeyString];
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

- (void)setKeyString
{
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
}

#pragma mark - 获取地理信息并存储到本地
- (void)requestData
{
    [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    
    self.updateTime = [[[NSUserDefaults standardUserDefaults] objectForKey:self.keyForUpdateTime] longLongValue];
    GetAreaInfoOp * op = [GetAreaInfoOp operation];
    op.req_updateTime = self.updateTime;
    op.req_type = self.areaType;
    op.req_areaId = self.areaId;
    @weakify(self);
    [[op rac_postRequest] subscribeNext:^(GetAreaInfoOp * op) {
        
        @strongify(self);
        //返回列表不为空
        if (op.rsp_areaArray.count != 0) {
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@(op.rsp_maxTime) forKey:self.keyForUpdateTime];
            NSMutableArray * userAreaArray = [defaults objectForKey:self.keyForArea];
            
            if (userAreaArray.count == 0) {
                [self setAreaDataSource:op.rsp_areaArray];
                self.dataSource = op.rsp_areaArray;
            }
            else {
                [self updateAreaDataSource:op.rsp_areaArray forArray:userAreaArray];
            }
        }
        //返回列表为空，直接读取本地数据
        else {
            [self getAreaFromUserDefaults];
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

#pragma mark - 编码
- (NSMutableArray *)archiverData:(NSArray *)originArray
{
    NSMutableArray * archiverArray = [NSMutableArray new];
    for (HKAreaInfoModel *areaModel in originArray) {
        NSData *areaEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:areaModel];
        [archiverArray addObject:areaEncodedObject];
    }
    return archiverArray;
}

#pragma mark - 解码
- (NSMutableArray *)unArchiverData:(NSArray *)originArray
{
    NSMutableArray * unArchiverArray = [NSMutableArray new];
    for (NSData *areaData in originArray) {
        HKAreaInfoModel *areaObject = [NSKeyedUnarchiver unarchiveObjectWithData:areaData];
        [unArchiverArray addObject:areaObject];
    }
    return unArchiverArray;
}

#pragma mark - 将地区信息编码后存储
- (void)setAreaDataSource:(NSArray *)areaArray
{
    NSMutableArray * tempMuteArray = [self archiverData:areaArray];
    [[NSUserDefaults standardUserDefaults] setObject:tempMuteArray forKey:self.keyForArea];
}

#pragma mark - 增量更新地区信息
- (void)updateAreaDataSource:(NSArray *)newAreaArray forArray:(NSMutableArray *)userAreaArray
{
    NSMutableArray * tempMuteArray = [self unArchiverData:userAreaArray];
    for (HKAreaInfoModel * newObj in newAreaArray)
    {
        BOOL isExsit = NO;
        for (int i = 0; i < tempMuteArray.count; i++) {
            HKAreaInfoModel *oldObj = [tempMuteArray safetyObjectAtIndex:i];
            
            if (newObj.infoId == oldObj.infoId)
            {
                isExsit = YES;
                if ([newObj.flag isEqualToString:@"D"])
                {
                    [tempMuteArray removeObjectAtIndex:i];
                }
                else if ([newObj.flag isEqualToString:@"U"])
                {
                    [tempMuteArray safetyReplaceObjectAtIndex:i withObject:newObj];
                }
                else if ([newObj.flag isEqualToString:@"A"])
                {
                    [tempMuteArray safetyReplaceObjectAtIndex:i withObject:newObj];
                }
                break;
            }
        }
        if(!isExsit) {
            [tempMuteArray safetyAddObject:newObj];
        }
    }
    [tempMuteArray sortUsingComparator:^NSComparisonResult(HKAreaInfoModel * obj1, HKAreaInfoModel * obj2) {
        return obj1.infoId > obj2.infoId;
    }];
    self.dataSource = tempMuteArray;
    
    NSMutableArray * archiverArray = [self archiverData:tempMuteArray];
    [[NSUserDefaults standardUserDefaults] setObject:archiverArray forKey:self.keyForArea];
}

#pragma mark - 读取本地地区信息并解码
- (void)getAreaFromUserDefaults
{
    NSArray * userDefaultArr = [[NSArray alloc] init];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    userDefaultArr = [defaults objectForKey:self.keyForArea];
    
    NSMutableArray * tempMuteArray = [self unArchiverData:userDefaultArr];
    self.dataSource = tempMuteArray;
}

#pragma mark - TabelViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.areaType == AreaTypeProvince) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
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
    if (self.dataSource.count == 0) {
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
        
        if (self.dataSource.count == 0) {
            label.text = @"全部地区";
        }
        else {
            HKAreaInfoModel *areaObject = [self.dataSource safetyObjectAtIndex:indexPath.row];
            label.text = areaObject.infoName;
        }
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
            GetAreaByPcdOp * op = [GetAreaByPcdOp operation];
            op.req_province = self.locationData.province;
            op.req_city = self.locationData.city;
            op.req_district = self.locationData.district;
            @weakify(self);
            [[op rac_postRequest] subscribeNext:^(GetAreaByPcdOp * op) {
                
                @strongify(self);
                HKAreaInfoModel * provinceModel = op.rsp_province;
                HKAreaInfoModel * cityModel = op.rsp_city;
                HKAreaInfoModel * districtModel = op.rsp_district;
                if (self.selectCompleteAction) {
                    self.selectCompleteAction(provinceModel, cityModel, districtModel);
                }
                if (self.originVC) {
                    [self.navigationController popToViewController:self.originVC animated:YES];
                }
                else {
                    [self.navigationController popViewControllerAnimated:YES];
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
            
            if (self.dataSource.count == 0) {
                HKAreaInfoModel * districtDic = [[HKAreaInfoModel alloc] init];
                districtDic.infoName = @"全部地区";
                if (self.selectCompleteAction) {
                    self.selectCompleteAction(provinceModel, cityModel, districtDic);
                }
            }
            else {
                HKAreaInfoModel * districtModel = areaObject;
                if (self.selectCompleteAction) {
                    self.selectCompleteAction(provinceModel, cityModel, districtModel);
                }
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





@end
