//
//  CityPickerVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/15.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "CityPickerVC.h"
#import "HKAddressComponent.h"
#import "GetAreaByNameOp.h"
#import "GetAreaByIdOp.h"

typedef NS_ENUM(NSInteger, LocateState) {
    LocateStateLocating,    //定位中
    LocateStateSuccess,     //定位成功
    LocateStateFailure     //定位失败
};

@interface CityPickerVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) NSArray *areaList;
@property (nonatomic, strong) NSMutableDictionary *areaCache;
@property (nonatomic, assign) LocateState locateState;
@property (nonatomic, strong) NSArray *locateAreas;
@property (nonatomic, weak) UIViewController *originVC;
@end

@implementation CityPickerVC

+ (instancetype)cityPickerVCWithOriginVC:(UIViewController *)originVC
{
    CityPickerVC * vc = [UIStoryboard vcWithId:@"CityPickerVC" inStoryboard:@"Common"];
    vc.originVC = originVC;
    return vc;
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"CityPickerVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.options & CityPickerOptionGPS) {
        [self requestLocation];
    }
    CKAsyncMainQueue(^{
        [self requestAreas];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)actionBack:(id)sender
{
    if (self.originVC) {
        [self.navigationController popToViewController:self.originVC animated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Request
- (void)reloadData
{
    if (self.locateState == LocateStateFailure) {
        [self requestLocation];
    }
    [self requestAreas];
}

- (void)requestLocation
{
    @weakify(self);
    [[[[gMapHelper rac_getUserLocationAndInvertGeoInfo] initially:^{
        
        @strongify(self);
        self.locateState = LocateStateLocating;
    }] flattenMap:^RACStream *(id value) {
        
        GetAreaByNameOp *op = [GetAreaByNameOp operation];
        op.req_province = gMapHelper.addrComponent.province;
        op.req_city = gMapHelper.addrComponent.city;
        op.req_district = gMapHelper.addrComponent.district;
        return [op rac_postRequest];
    }] subscribeNext:^(GetAreaByNameOp *op) {
        
        @strongify(self);
        self.locateState = LocateStateSuccess;
        self.locateAreas = @[op.rsp_province, op.rsp_city, op.rsp_district];
    } error:^(NSError *error) {
        
        @strongify(self);
        self.locateState = LocateStateFailure;
    }];
}

- (void)requestAreas
{
    GetAreaByIdOp * op = [GetAreaByIdOp operation];
    op.req_updateTime = 0;
    NSInteger type = 0;
    if (self.options & CityPickerOptionProvince) {
        type = 1;
    }
    else if (self.options & CityPickerOptionCity) {
        type = 2;
    }
    else if (self.options & CityPickerOptionDistrict) {
        type = 3;
    }
    op.req_type = type;
    op.req_areaId = self.parentArea.aid;
    op.req_updateTime = 0;
    @weakify(self);
    [[[[op rac_postRequest] initially:^{
        
        @strongify(self);
        if ([self.tableView isRefreshViewExists]) {
            [self.tableView.refreshView beginRefreshing];
        }
        else {
            self.containerView.hidden = YES;
            [self.view hideDefaultEmptyView];
            [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        }
    }] finally:^{
      
        @strongify(self);
        [self.view stopActivityAnimation];
    }] subscribeNext:^(GetAreaByIdOp *op) {
        
        @strongify(self);
        if ([self.tableView isRefreshViewExists]) {
            [self.tableView.refreshView endRefreshing];
        }
        else {
            self.containerView.hidden = NO;
            [self.tableView.refreshView addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
        }
        self.areaList = op.rsp_areaArray;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        if ([self.tableView isRefreshViewExists]) {
            [self.tableView.refreshView endRefreshing];
            return;
        }
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"获取信息失败，点击重试" tapBlock:^{
            @strongify(self);
            [self requestAreas];
        }];
    }];
}
#pragma mark - Utility
- (void)gotoNextOrBackWithCurrentArea:(Area *)anArea
{
    if (!self.areaCache) {
        self.areaCache = [NSMutableDictionary dictionary];
    }
    [self.areaCache safetySetObject:anArea forKey:@(anArea.level)];

    NSUInteger nextOptions = self.options & ~CityPickerOptionGPS;
    if (nextOptions & CityPickerOptionProvince) {
        nextOptions = nextOptions & ~CityPickerOptionProvince;
    }
    else if (nextOptions & CityPickerOptionCity) {
        nextOptions = nextOptions & ~CityPickerOptionCity;
    }
    else if (nextOptions & CityPickerOptionDistrict) {
        nextOptions = nextOptions & ~CityPickerOptionDistrict;
    }
    if (nextOptions == CityPickerOptionNone) {
        if (self.completedBlock) {
            [self actionBack:nil];
            self.completedBlock(self,
                                [self.areaCache objectForKey:@(AreaLevelProvince)],
                                [self.areaCache objectForKey:@(AreaLevelCity)],
                                [self.areaCache objectForKey:@(AreaLevelDistrict)]);
        }
    }
    else {
        CityPickerVC *nextvc = [CityPickerVC cityPickerVCWithOriginVC:self.originVC ];
        nextvc.options = nextOptions;
        nextvc.completedBlock = self.completedBlock;
        nextvc.parentArea = anArea;
        nextvc.areaCache = self.areaCache;
        [self.navigationController pushViewController:nextvc animated:YES];
    }
}

#pragma mark - UITableViewDelegate and datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.options & CityPickerOptionGPS) {
        return 2;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0 && (self.options & CityPickerOptionGPS)) {
        return @"定位到的位置";
    }
    return @"全部";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((self.options & CityPickerOptionGPS) && section == 0) {
        return 1;
    }
    return self.areaList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isGPSCell = indexPath.section == 0 && (self.options & CityPickerOptionGPS
                                                );
    NSString *cellID = isGPSCell ? @"GpsCell" : @"LabelCell";
    JTTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if (isGPSCell) {
        [self resetGPSCell:cell atIndexPath:indexPath];
    }
    else {
        [self resetLabelCell:cell atIndexPath:indexPath];
    }
    
    [cell prepareCellForTableView:tableView atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //点击定位
    if (indexPath.section == 0 && (self.options & CityPickerOptionGPS)) {
        //定位失败，重新定位
        if (self.locateState == LocateStateFailure) {
            [self requestLocation];
        }
        //定位成功，返回数据
        else if (self.locateState == LocateStateSuccess) {
            [self actionBack:nil];
            if (self.completedBlock) {
                self.completedBlock(self,
                                    [self.locateAreas safetyObjectAtIndex:0],
                                    [self.locateAreas safetyObjectAtIndex:1],
                                    [self.locateAreas safetyObjectAtIndex:2]);
            }
        }
    }
    else {
        [self gotoNextOrBackWithCurrentArea:[self.areaList safetyObjectAtIndex:indexPath.row]];
    }
}

#pragma mark - Cell
- (void)resetGPSCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    UILabel * label = [cell.contentView viewWithTag:1001];
    UIActivityIndicatorView * activityView = [cell.contentView viewWithTag:1002];
    [[RACObserve(self, locateState) takeUntilForCell:cell] subscribeNext:^(id x) {
        LocateState state = [x integerValue];
        if (state == LocateStateLocating) {     //定位中
            [activityView startAnimating];
            label.text = @"定位中...";
        }
        else if (state == LocateStateFailure) { //定位失败
            [activityView stopAnimating];
            label.text = @"定位失败";
        }
        else if (state == LocateStateSuccess) { //定位成功
            [activityView stopAnimating];
            NSArray *components = [self.locateAreas arrayByMapFilteringOperator:^id(Area *area) {
                return area.name;
            }];
            label.text = [components componentsJoinedByString:@" "];
        }
    }];
}

- (void)resetLabelCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Area *area = [self.areaList safetyObjectAtIndex:indexPath.row];
    UILabel * label = [cell.contentView viewWithTag:1001];
    label.text = area.name;
}

@end
