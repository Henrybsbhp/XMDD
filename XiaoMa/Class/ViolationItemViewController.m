//
//  IllegalItemViewController.m
//  XiaoMa
//
//  Created by jt on 15/11/24.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "ViolationItemViewController.h"
#import "HKViolation.h"
#import "NSDate+DateForText.h"
#import "NSString+RectSize.h"
#import "UIView+Shake.h"
#import "EditCarVC.h"
#import "HKLocationDataModel.h"
#import "GetCityInfoByNameOp.h"
#import "AreaTablePickerVC.h"
#import "CarIDCodeCheckModel.h"

#import "MyUIPageControl.h"



@interface ViolationItemViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)NSArray * infoArray;

///城市按钮
@property (nonatomic,weak)UIButton * cityBtn;
/// 旋转动画
@property (nonatomic,weak)UIButton * queryBtn;
@property (nonatomic,strong)CABasicAnimation * animation;
@property (nonatomic)BOOL isQuerying;

/// 是否展开
@property (nonatomic)BOOL isSpread;

/// 是否城市信息获取的状态
@property (nonatomic)BOOL isCityLoading;

/// 临时存放
@property (nonatomic,copy)NSString * tempCityName;

@end

@implementation ViolationItemViewController

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"ViolationItemViewController dealloc");
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp901"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp901"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CKAsyncMainQueue(^{
        [self setupUI];
    });
    if (self.car)
    {
        [self setupData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  Utility
- (void)setupUI
{
    /// 旋转动画
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 8.0f;
    rotationAnimation.repeatCount = FLT_MAX;
    rotationAnimation.cumulative = NO;
    
    self.animation = rotationAnimation;
    
    
    CGFloat inset = self.carArray.count ? 30 : 10;
    self.tableView.contentInset = UIEdgeInsetsMake(inset, 0, 0, 0);
    [self.tableView setContentOffset:CGPointMake(0, -inset) animated:YES];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
}


- (void)setupData
{
    if (!self.model)
    {
        self.model = [[ViolationModel alloc] init];
        self.model.licencenumber = self.car.licencenumber;
        self.model.classno = self.car.classno;
        self.model.engineno = self.car.engineno;
        
        [[[[self.model rac_getLocalUserViolation] flattenMap:^RACStream *(id value) {
            
            if (!self.model.cityInfo.provinceName.length || !self.model.cityInfo.cityName.length)
            {
                /// 爱车和上次查询都没有地理信息
                if (!self.car.provinceName.length || !self.car.cithName.length)
                {
                    return [self rac_autoLocateCity];
                }
                /// 爱车有地理信息
                else
                {
                    return [self rac_requestCityInfoWithProvince:self.car.provinceName andCith:self.car.cithName];
                }
            }
            else
            {
                // 直接返回信号
                return [RACSignal return:self.model];
            }
        }] initially:^{
            
            self.isCityLoading = YES;
        }] subscribeNext:^(NSObject * obj) {
            
            // 说明进行过城市信息的获取
            if ([obj isKindOfClass:[GetCityInfoByNameOp class]])
            {
                self.isSpread = YES;
                self.model.cityInfo = ((GetCityInfoByNameOp *)obj).cityInfo;
            }
            // 从本地获取的城市信息
            else
            {
                self.isSpread = !self.model.queryDate;
            }
            self.isCityLoading = NO;
            self.tempCityName = self.model.cityInfo.cityName;
            [self handleViolationCityInfo];
            [self.tableView reloadData];
        } error:^(NSError *error) {
            
            self.isCityLoading = NO;
        }];
    }
    self.isSpread = !self.model.queryDate;
    self.tempCityName = self.model.cityInfo.cityName;
}
- (void)handleViolationCityInfo
{
    NSMutableArray * tArray = [NSMutableArray array];
    
    if (self.model.cityInfo.isClassNum)
    {
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"车架号码",
                                                                                     @"suffixno":@(self.model.cityInfo.classSuffixNum)}];
        [dict safetySetObject:self.model.classno forKey:@"no"];
        [tArray safetyAddObject:dict];
    }
    if (self.model.cityInfo.isEngineNum)
    {
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"发动机号",
                                                                                     @"suffixno":@(self.model.cityInfo.engineSuffixNum)}];
        [dict safetySetObject:self.model.engineno forKey:@"no"];
        [tArray safetyAddObject:dict];
    }
    
    self.infoArray = [NSArray arrayWithArray:tArray];
}

#pragma mark - Network
/// 请求违章
- (void)requesQueryViolation
{
    self.model.licencenumber = self.car.licencenumber;
    self.model.cid = self.car.carId;
    
    [[[self.model rac_requestUserViolation] initially:^{
        
        self.isQuerying = YES;
        [self queryTransform];
    }] subscribeNext:^(id x) {
        
        self.isQuerying = NO;
        [self stopQueryTransform];
        self.isSpread = NO;
        
        [self handleViolationCityInfo];
        [self.tableView reloadData];
        
    } error:^(NSError *error) {
        
        self.isQuerying = NO;
        [self stopQueryTransform];
        [self.tableView reloadData];
        [gToast showError:error.domain];
    }];
}

- (RACSignal *)rac_requestCityInfoWithProvince:(NSString *)p andCith:(NSString *)c
{
    GetAreaByPcdOp * op = [GetAreaByPcdOp operation];
    op.req_province = p;
    op.req_city = c;
    
    return [[op rac_postRequest] flattenMap:^RACStream *(GetAreaByPcdOp * op) {
        
        GetCityInfoByNameOp * getCityInfoByNameOp = [[GetCityInfoByNameOp alloc] init];
        getCityInfoByNameOp.province = op.rsp_province.infoName;
        getCityInfoByNameOp.city = op.rsp_city.infoName;
        
        return [getCityInfoByNameOp rac_postRequest];
    }];
}

#pragma mark - Utility
- (void)queryAction
{
    
    if (self.model.cityInfo.cityCode.length <=  0)
    {
        [self.cityBtn.superview.subviews makeObjectsPerformSelector:@selector(shake)];
        return;
    }
    
    /// 有发动机，车价输入框
    for (NSDictionary * dict in self.infoArray)
    {
        UITextField * feild = [dict objectForKey:@"feild"];
        NSInteger num = [dict[@"suffixno"] integerValue];
        if (feild)
        {
            /// 输入的小于限制或者等于0
            if ((feild.text.length < num && num > 0) ||
                feild.text.length == 0)
            {
                CGFloat delay = self.isSpread ? 0.0f : 1.0f;
                
                [self insertCityInfoCell];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [feild.superview.subviews makeObjectsPerformSelector:@selector(shake)];
                });
                return;
            }
            
            if ([dict[@"title"] isEqualToString:@"发动机号"])
            {
                self.model.engineno = feild.text;
            }
            else if ([dict[@"title"] isEqualToString:@"车架号码"])
            {
                ///说明要求输入完整车架号，此时验证
                if (num == 0)
                {
                    if (![CarIDCodeCheckModel carIDCheckWithCodeStr:feild.text])
                    {
                        [gToast showError:@"请输入正确的车架号码"];
                        return;
                    }
                }
                self.model.classno = feild.text;
            }
        }
        else
        {
            if (self.model.engineno.length == 0 && self.model.classno.length == 0)
            {
                CGFloat delay = self.isSpread ? 0.0f : 1.0f;
                
                [self insertCityInfoCell];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [feild.superview.subviews makeObjectsPerformSelector:@selector(shake)];
                });
                return;
            }
        }
    }
    
    [self requesQueryViolation];
}



- (void)queryTransform
{
    UIImageView * animationView = self.queryBtn.imageView;
    
    [self.queryBtn setImage:[UIImage imageNamed:@"loading_white"] forState:UIControlStateNormal];
    [self.queryBtn setImage:[UIImage imageNamed:@"loading_white"] forState:UIControlStateHighlighted];
    
    
    CFTimeInterval pausedTime = [animationView.layer timeOffset];
    animationView.layer.speed = 1.0;
    animationView.layer.timeOffset = 0.0;
    animationView.layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [animationView.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    animationView.layer.beginTime = timeSincePause;
}

- (void)stopQueryTransform
{
    UIImageView * animationView = self.queryBtn.imageView;
    CFTimeInterval pausedTime = [animationView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    animationView.layer.speed = 0.0;
    animationView.layer.timeOffset = pausedTime;
    
    if (!self.model.queryDate)
    {
        [self.queryBtn setImage:[UIImage imageNamed:@"search_white"] forState:UIControlStateNormal];
        [self.queryBtn setImage:[UIImage imageNamed:@"search_white"] forState:UIControlStateHighlighted];
        [self.queryBtn setTitle:@"   查询违章信息" forState:UIControlStateNormal];
        [self.queryBtn setTitle:@"   查询违章信息" forState:UIControlStateHighlighted];
    }
    else
    {
        [self.queryBtn setImage:[UIImage imageNamed:@"loading_white"] forState:UIControlStateNormal];
        [self.queryBtn setImage:[UIImage imageNamed:@"loading_white"] forState:UIControlStateHighlighted];
        [self.queryBtn setTitle:@"   更新违章信息" forState:UIControlStateNormal];
        [self.queryBtn setTitle:@"   更新违章信息" forState:UIControlStateHighlighted];
    }
}


- (void)insertCityInfoCell
{
    if (self.isSpread)
        return;
    self.isSpread = YES;
    NSMutableArray * array = [NSMutableArray array];
    for (NSInteger i = 0; i < self.infoArray.count; i++)
    {
        NSIndexPath  * path = [NSIndexPath indexPathForRow:i + 2 inSection:0];
        [array safetyAddObject:path];
    }
    NSIndexPath  * path = [NSIndexPath indexPathForRow:self.infoArray.count + 2 inSection:0];
    [array safetyAddObject:path];
    
    [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationBottom];
}

- (void)deleteCityInfoCell
{
    if (!self.isSpread)
        return;
    self.isSpread = NO;
    NSMutableArray * array = [NSMutableArray array];
    for (NSInteger i = 0; i < self.infoArray.count; i++)
    {
        NSIndexPath  * path = [NSIndexPath indexPathForRow:i + 2 inSection:0];
        [array safetyAddObject:path];
    }
    NSIndexPath  * path = [NSIndexPath indexPathForRow:self.infoArray.count + 2 inSection:0];
    [array safetyAddObject:path];
    [self.tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
}


- (void)selectCityAction
{
    AreaTablePickerVC * vc = [AreaTablePickerVC initPickerAreaVCWithType:PickerVCTypeProvinceAndCity fromVC:self.parentViewController];
    
    [vc setSelectCompleteAction:^(HKAreaInfoModel * provinceModel, HKAreaInfoModel * cityModel, HKAreaInfoModel * disctrictModel) {
        
        self.tempCityName = cityModel.infoName;
        [self handleRequestCityInfoWithProvince:provinceModel.infoName andCith:cityModel.infoName];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}



- (void)handleRequestCityInfoWithProvince:(NSString *)p andCith:(NSString *)c
{
    RACSignal * signal = [self rac_requestCityInfoWithProvince:p andCith:c];
    
    [[signal initially:^{
        
        self.isCityLoading = YES;
    }] subscribeNext:^(GetCityInfoByNameOp * op) {
        
        self.isCityLoading = NO;
        self.isSpread = YES;
        
        if (op.cityInfo.cityCode.length)
        {
            ViolationCityInfo * info = op.cityInfo;
            self.model.cityInfo = info;
            self.tempCityName = info.cityName;
            [self handleViolationCityInfo];
        }
        else
        {
            self.tempCityName = self.model.cityInfo.cityName;
            [gToast showError:@"该城市暂不支持违章查询"];
        }
        
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        
    } error:^(NSError *error) {
        
        self.tempCityName = self.model.cityInfo.cityName;
        self.isCityLoading = NO;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        [gToast showError:error.domain];
    }];
}


- (RACSignal *)rac_autoLocateCity
{
    RACSignal * signal;
    if (gMapHelper.addrComponent.province.length && gMapHelper.addrComponent.city)
    {
        signal = [self rac_requestCityInfoWithProvince:gMapHelper.addrComponent.province andCith:gMapHelper.addrComponent.city];
    }
    else
    {
        signal =[[gMapHelper rac_getInvertGeoInfo] flattenMap:^RACStream *(id value) {
            
            return [self rac_requestCityInfoWithProvince:gMapHelper.addrComponent.province andCith:gMapHelper.addrComponent.city];
        }];
    }
    return signal;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1)
    {
        return CGFLOAT_MIN;
    }
    return 8.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height =  44;
    
    if (!self.car)
    {
        return 200;
    }
    
    if (indexPath.section == 0)
    {
        NSInteger num;
        if (self.isSpread)
        {
            /// num = 车牌 + 城市 + self.infoArray.count +如何填写 + 分割线 + 搜索框
            num = 5 + self.infoArray.count;
            
            if (indexPath.row == 0)
            {
                height = 40;
            }
            else if (indexPath.row == 1)
            {
                height = 44;
            }
            else if (indexPath.row == num - 1)
            {
                height = 84;
            }
            else if (indexPath.row == num - 2)
            {
                height = 24;
            }
            else if (indexPath.row == num - 3)
            {
                height = 26;
            }
            else
            {
                height = 44;
            }
        }
        else
        {
            /// 4 = 车牌 + 城市 + 分割线 + 搜索框
            num = 4;
            
            if (indexPath.row == 0)
            {
                height = 40;
            }
            else if (indexPath.row == 1)
            {
                height = 44;
            }
            else if (indexPath.row == num - 1)
            {
                height = 84;
            }
            else if (indexPath.row == num - 2)
            {
                height = 24;
            }
        }
    }
    else
    {
        if (indexPath.row == 0)
        {
            if (self.model.violationArray.count)
            {
                height = 44;
            }
            else
            {
                height = 240;
            }
        }
        else
        {
            HKViolation * violation = [self.model.violationArray safetyObjectAtIndex:indexPath.row - 1];
            
            //            if (!violation.customTag)
            {
                CGFloat width1 = gAppMgr.deviceInfo.screenSize.width - 60;
                CGSize size1 = [violation.violationArea labelSizeWithWidth:width1 font:[UIFont systemFontOfSize:12]];
                
                CGFloat width2 = gAppMgr.deviceInfo.screenSize.width - 45;
                CGSize size2 = [violation.violationAct labelSizeWithWidth:width2 font:[UIFont systemFontOfSize:15]];
                
                height = 63 + size1.height + 16 + size2.height + 14;
                //                violation.customTag = height;
            }
            //            height = violation.customTag;
        }
    }
    return height;
}





- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (!self.car)
    {
        return 1;
    }
    if (self.model.violationArray.count)
    {
        return 2;
    }
    else
    {
        /// 查询过
        if (self.model.queryDate)
        {
            return 2;
        }
        else
        {
            return 1;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger num = 0;
    if (!self.car)
    {
        return 1;
    }
    if (section == 0)
    {
        if (self.isSpread)
        {
            /// 5 = 车牌 + 城市 + 如何填写 + 分割线 + 搜索框
            num = 5 + self.infoArray.count;
        }
        else
        {
            /// 4 = 车牌 + 城市 + 分割线 + 搜索框
            num = 4;
        }
    }
    else
    {
        num = self.model.violationArray.count + 1;
    }
    return num;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, gAppMgr.deviceInfo.screenSize.width, 8)];
    view.backgroundColor = [UIColor colorWithHex:@"#f4f4f4" alpha:1.0f];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell;
    if (!self.car)
    {
        cell = [self addCarCellAtIndexPath:indexPath];
        return cell;
    }
    if (indexPath.section == 0)
    {
        NSInteger num;
        if (self.isSpread)
        {
            /// num = 车牌 + 城市 + self.infoArray.count +如何填写 + 分割线 + 搜索框
            num = 5 + self.infoArray.count;
            
            if (indexPath.row == 0)
            {
                cell = [self lisenceNumCellAtIndexPath:indexPath];
            }
            else if (indexPath.row == 1)
            {
                cell = [self cityInputCellAtIndexPath:indexPath];
            }
            else if (indexPath.row == num - 1)
            {
                cell = [self searchBtnCellAtIndexPath:indexPath];
            }
            else if (indexPath.row == num - 2)
            {
                cell = [self separatorCellAtIndexPath:indexPath];
            }
            else if (indexPath.row == num - 3)
            {
                cell = [self howInputCellAtIndexPath:indexPath];
            }
            else
            {
                cell = [self infoInputCellAtIndexPath:indexPath];
            }
        }
        else
        {
            /// 4 = 车牌 + 城市 + 分割线 + 搜索框
            num = 4;
            
            if (indexPath.row == 0)
            {
                cell = [self lisenceNumCellAtIndexPath:indexPath];
            }
            else if (indexPath.row == 1)
            {
                cell = [self cityInputCellAtIndexPath:indexPath];
            }
            else if (indexPath.row == num - 1)
            {
                cell = [self searchBtnCellAtIndexPath:indexPath];
            }
            else
            {
                cell = [self separatorCellAtIndexPath:indexPath];
            }
        }
    }
    else
    {
        if (indexPath.row == 0)
        {
            if (self.model.violationArray.count)
            {
                cell = [self violationTitleCellAtIndexPath:indexPath];
            }
            else
            {
                cell = [self encourageCellAtIndexPath:indexPath];
            }
            
        }
        else
        {
            cell = [self violationItemCellAtIndexPath:indexPath];
        }
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier  isEqualToString:@"AddCarCell"])
    {
        /**
         *  添加车辆点击事件
         */
        [MobClick event:@"rp901-1"];
        EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([cell.reuseIdentifier  isEqualToString:@"SeparatorCell"])
    {
        UIImageView * statusImgV = (UIImageView *)[cell searchViewWithTag:101];
        if (self.isSpread)
        {
            [self deleteCityInfoCell];
            
        }
        else
        {
            [self insertCityInfoCell];
        }
        statusImgV.transform = CGAffineTransformRotate(statusImgV.transform,M_PI);
    }
}



#pragma mark - Tableview Utility
- (UITableViewCell *)lisenceNumCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LisenceNumCell"];
    
    // 车牌号
    UILabel * lisenceNumL = (UILabel *)[cell searchViewWithTag:101];
    lisenceNumL.text = self.car.licencenumber;
    return cell;
}

- (UITableViewCell *)cityInputCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CityInputCell"];
    
    UIActivityIndicatorView * ai = (UIActivityIndicatorView *)[cell searchViewWithTag:102];
    ai.hidden = !self.isCityLoading;
    ai.animating = self.isCityLoading;
    
    UIButton * cityBtn = (UIButton *)[cell searchViewWithTag:101];
    
    cityBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [[RACObserve(self, isCityLoading) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSNumber * number) {
        
        ai.hidden = ![number integerValue];
        ai.animating = [number integerValue];
    }];
    
    
    [[[RACObserve(self,tempCityName) distinctUntilChanged] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSString * city) {
        /**
         *  行驶城市点击事件
         */
        [MobClick event:@"rp901-3"];
        [cityBtn setTitle:city forState:UIControlStateNormal];
    }];
    // 城市点击区域
    @weakify(self)
    [[[cityBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self)
        [self selectCityAction];
    }];
    
    self.cityBtn = cityBtn;
    
    return cell;
}

- (UITableViewCell *)infoInputCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"InfoInputCell"];
    NSMutableDictionary * dict = [self.infoArray safetyObjectAtIndex:indexPath.row - 2];
    
    // 标题
    UILabel * titleLb = (UILabel *)[cell searchViewWithTag:101];
    titleLb.text = dict[@"title"];
    
    // 副标题
    UILabel * subtitleLb = (UILabel *)[cell searchViewWithTag:102];
    NSInteger num = [dict[@"suffixno"] integerValue];
    if (num > 0)
    {
        subtitleLb.text = [NSString stringWithFormat:@"(后%ld位)",(long)num];
    }
    else
    {
        subtitleLb.text = [NSString stringWithFormat:@"(全填)"];
    }
    
    //输入框
    UITextField * field = (UITextField *)[cell searchViewWithTag:103];
    field.text = [dict objectForKey:@"no"];
    [dict safetySetObject:field forKey:@"feild"];
    
    @weakify(field);
    [[field rac_textSignal] subscribeNext:^(id x) {
        /**
         *  发动机号点击事件
         */
        [MobClick event:@"rp901-4"];
        @strongify(field)
        field.text = [field.text uppercaseString];
        
        if ([dict[@"title"] isEqualToString:@"发动机号"])
        {
            self.model.engineno = field.text;
            [dict safetySetObject:self.model.engineno forKey:@"no"];
        }
        else
        {
            self.model.classno = field.text;
            [dict safetySetObject:self.model.classno forKey:@"no"];
        }
    }];
    
    return cell;
}

- (UITableViewCell *)searchBtnCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SearchBtnCell"];
    
    // 查询按钮
    UIButton * queryBtn = (UIButton *)[cell searchViewWithTag:101];
    [queryBtn setTitle:@"查询违章信息" forState:UIControlStateNormal || UIControlStateHighlighted];
    UIImageView * animationView = queryBtn.imageView;
    if (!self.model.queryDate)
    {
        [self.queryBtn setImage:[UIImage imageNamed:@"search_white"] forState:UIControlStateNormal];
        [self.queryBtn setImage:[UIImage imageNamed:@"search_white"] forState:UIControlStateHighlighted];
        [self.queryBtn setTitle:@"   查询违章信息" forState:UIControlStateNormal];
        [self.queryBtn setTitle:@"   查询违章信息" forState:UIControlStateHighlighted];
    }
    else
    {
        [self.queryBtn setImage:[UIImage imageNamed:@"loading_white"] forState:UIControlStateNormal];
        [self.queryBtn setImage:[UIImage imageNamed:@"loading_white"] forState:UIControlStateHighlighted];
        [self.queryBtn setTitle:@"   更新违章信息" forState:UIControlStateNormal];
        [self.queryBtn setTitle:@"   更新违章信息" forState:UIControlStateHighlighted];
    }
    NSArray  * array = animationView.layer.animationKeys;
    if (!array.count)
    {
        {
            [animationView.layer addAnimation:self.animation forKey:@"a"];
            if (!self.isQuerying) {
                animationView.layer.speed = 0.0;
            }
            else
            {
                animationView.layer.speed = 1.0f;
            }
        }
    }
    
    
    @weakify(self)
    [[[queryBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self)
        if (!self.isQuerying)
        {
            /**
             *  查询按钮点击事件
             */
            [MobClick event:@"rp901-2"];
            [self queryAction];
        }
        else
        {
            /**
             *  更新违章点击事件
             */
            [MobClick event:@"rp901-6"];
            [gToast showText:@"小马达达正在努力查询中\n请别着急"];
        }
    }];
    
    self.queryBtn = queryBtn;
    
    // 按钮下面的小标题
    UILabel * subtitleLb = (UILabel *)[cell searchViewWithTag:102];
    if (self.model.queryDate)
    {
        NSString * str = [NSString stringWithFormat:@"您于%@更新了%ld条信息",[self.model.queryDate dateFormatForYYYYMMddHHmm2],(unsigned long)self.model.violationArray.count];
        subtitleLb.text = str;
    }
    else
    {
        subtitleLb.text = @"暂无更新信息";
    }
    
    return cell;
}

- (UITableViewCell *)violationTitleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ViolationTitleCell"];
    
    // 违章标题
    UILabel * titleLb = (UILabel *)[cell searchViewWithTag:101];
    titleLb.text = [NSString stringWithFormat:@"罚款%ld元，共扣%ld分",(long)self.model.violationTotalmoney,(long)self.model.violationTotalfen];
    
    return cell;
}

- (UITableViewCell *)violationItemCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ViolationItemCell"];
    
    HKViolation * violation = [self.model.violationArray safetyObjectAtIndex:indexPath.row - 1];
    
    ///罚款icon
    UIImageView * moneyImgV = (UIImageView *)[cell searchViewWithTag:107];
    
    ///罚分icon
    UIImageView * fenImgV = (UIImageView *)[cell searchViewWithTag:108];
    
    ///罚款标志
    UILabel * moneyLb = (UILabel *)[cell searchViewWithTag:101];
    moneyLb.text = violation.violationMoney.length ? violation.violationMoney : @"未知";
    
    ///罚分标志
    UILabel * fenLb = (UILabel *)[cell searchViewWithTag:102];
    fenLb.text = violation.violationScore.length ? violation.violationScore : @"未知";
    
    ///处理情况图标
    UIImageView * handleIcon = (UIImageView *)[cell searchViewWithTag:103];
    
    ///时间标志
    UILabel * whenLb = (UILabel *)[cell searchViewWithTag:104];
    whenLb.text = violation.violationDate;
    
    ///地点标志
    UILabel * whereLb = (UILabel *)[cell searchViewWithTag:105];
    whereLb.text = violation.violationArea;
    
    ///原因标志
    UILabel * whyLb = (UILabel *)[cell searchViewWithTag:106];
    whyLb.text = violation.violationAct;
    
    if ([violation.ishandled isEqualToString:@"1"])
    {
        moneyImgV.image = [UIImage imageNamed:@"penalty_money_green_icon"];
        fenImgV.image = [UIImage imageNamed:@"penalty_fraction_green_icon"];
        handleIcon.image = [UIImage imageNamed:@"handle_icon"];
        moneyLb.textColor = [UIColor colorWithHex:@"#20ab2a" alpha:1.0f];
        fenLb.textColor = [UIColor colorWithHex:@"#20ab2a" alpha:1.0f];
    }
    else
    {
        moneyImgV.image = [UIImage imageNamed:@"penalty_money_icon"];
        fenImgV.image = [UIImage imageNamed:@"penalty_fraction_icon"];
        handleIcon.image = [UIImage imageNamed:@"unhandle_icon"];
        moneyLb.textColor = [UIColor colorWithHex:@"#ffa800" alpha:1.0f];
        fenLb.textColor = [UIColor colorWithHex:@"#ffa800" alpha:1.0f];
    }
    
    
    return cell;
}

- (UITableViewCell *)addCarCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"AddCarCell"];
    return cell;
}

- (UITableViewCell *)encourageCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"NoViolationCell"];
    return cell;
}

- (UITableViewCell *)howInputCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HowInputCell"];
    
    UIButton * btn = (UIButton *)[cell searchViewWithTag:101];
    [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        [self showPicture:@"violation_eg"];
    }];
    return cell;
}

- (UITableViewCell *)separatorCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SeparatorCell"];
    
    UIImageView * statusImgV = (UIImageView *)[cell searchViewWithTag:101];
    
    statusImgV.image = self.isSpread ? [UIImage imageNamed:@"violation_push"]:[UIImage imageNamed:@"violation_pull"];
    
    return cell;
}

- (void)showPicture:(NSString *)picname
{
    CGSize size = CGSizeMake(300, 200);
    UIViewController *vc = [[UIViewController alloc] init];
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:size viewController:vc];
    sheet.cornerRadius = 0;
    sheet.shadowRadius = 0;
    sheet.shadowOpacity = 0;
    sheet.transitionStyle = MZFormSheetTransitionStyleFade;
    sheet.shouldDismissOnBackgroundViewTap = YES;
    [MZFormSheetController sharedBackgroundWindow].backgroundBlurEffect = NO;
    sheet.portraitTopInset = floor((self.view.frame.size.height - size.height) / 2);
    
    [sheet presentAnimated:YES completionHandler:nil];
    
    vc.view.backgroundColor = [UIColor clearColor];
    UIImageView *imgv = [[UIImageView alloc] initWithFrame:vc.view.bounds];
    [vc.view addSubview:imgv];
    imgv.autoresizingMask = UIViewAutoresizingFlexibleAll;
    imgv.image = [UIImage imageNamed:picname];
}



@end
