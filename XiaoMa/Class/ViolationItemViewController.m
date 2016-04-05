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
#import "CKLimitTextField.h"

#import "MyUIPageControl.h"
#import "OETextField.h"



@interface ViolationItemViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic,strong)NSArray * infoArray;

///城市按钮
@property (nonatomic,weak)UIButton * cityBtn;
/// 旋转动画
@property (nonatomic,weak)UIButton * queryBtn;
@property (nonatomic,strong)CABasicAnimation * animation;
@property (nonatomic)BOOL isQuerying;


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
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = kBackgroundColor;
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
                if (!self.car.provinceName.length || !self.car.cityName.length)
                {
                    return [self rac_autoLocateCity];
                }
                /// 爱车有地理信息
                else
                {
                    return [self rac_requestCityInfoWithProvince:self.car.provinceName andCith:self.car.cityName];
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
                self.model.cityInfo = ((GetCityInfoByNameOp *)obj).cityInfo;
            }
            self.isCityLoading = NO;
            self.tempCityName = self.model.cityInfo.cityName;
            [self handleViolationCityInfo];
            [self.tableView reloadData];
        } error:^(NSError *error) {
            
            self.isCityLoading = NO;
        }];
    }
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
        /// 此城市从爱车带过来，但是不支持违章
        if (self.model.cityInfo.cityName.length)
        {
            [gToast showError:@"该城市暂不支持违章查询"];
        }
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
                [feild.superview.subviews makeObjectsPerformSelector:@selector(shake)];
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
                [feild.superview.subviews makeObjectsPerformSelector:@selector(shake)];
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

#pragma mark - TextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.customTag == 1031) {
        [MobClick event:@"rp901_4"];
    }
    else {
        [MobClick event:@"rp901_5"];
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height =  40;
    
    if (!self.car)
    {
        return 200;
    }
    
    if (indexPath.section == 0)
    {
        NSInteger num = 0;
        /// num = 城市 + self.infoArray.count + 搜索框
        num = 2 + self.infoArray.count;
        if (indexPath.row == num - 1)
        {
            height = 112;
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
            
            CGFloat width1 = gAppMgr.deviceInfo.screenSize.width - 60;
            CGSize size1 = [violation.violationArea labelSizeWithWidth:width1 font:[UIFont systemFontOfSize:12]];
            
            CGFloat width2 = gAppMgr.deviceInfo.screenSize.width - 45;
            CGSize size2 = [violation.violationAct labelSizeWithWidth:width2 font:[UIFont systemFontOfSize:15]];
            
            height = 63 + size1.height + 16 + size2.height + 14;
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
        /// num = 城市  + 搜索框 + self.infoArray
        num = 2 + self.infoArray.count;
    }
    else
    {
        num = self.model.violationArray.count + 1;
    }
    return num;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, gAppMgr.deviceInfo.screenSize.width, 8)];
    view.backgroundColor = section == 0 ? [UIColor whiteColor] : kBackgroundColor;
    
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
            /// num = 城市 + self.infoArray.count 搜索框
        num = 2 + self.infoArray.count;
            
            if (indexPath.row == 0)
            {
                cell = [self cityInputCellAtIndexPath:indexPath];
            }
            else if (indexPath.row == num - 1)
            {
                cell = [self searchBtnCellAtIndexPath:indexPath];
            }
            else
            {
                cell = [self infoInputCellAtIndexPath:indexPath];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([cell.reuseIdentifier isEqualToString:@"AddCarCell"])
    {
        /**
         *  添加车辆点击事件
         */
        [MobClick event:@"rp901_1"];
        EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
        [self.navigationController pushViewController:vc animated:YES];
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
    cityBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    [[RACObserve(self, isCityLoading) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSNumber * number) {
        
        ai.hidden = ![number integerValue];
        ai.animating = [number integerValue];
    }];
    
    
    [[[RACObserve(self,tempCityName) distinctUntilChanged] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSString * city) {
        [cityBtn setTitle:city forState:UIControlStateNormal];
    }];
    // 城市点击区域
    @weakify(self)
    [[[cityBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        [MobClick event:@"rp901_3"];
        @strongify(self)
        [self selectCityAction];
    }];
    
    self.cityBtn = cityBtn;
    
    return cell;
}

- (UITableViewCell *)infoInputCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"InfoInputCell"];
    NSMutableDictionary * dict = [self.infoArray safetyObjectAtIndex:indexPath.row - 1];
    
    // 标题
    UILabel * titleLb = (UILabel *)[cell searchViewWithTag:101];
    titleLb.text = dict[@"title"];
    
    UIButton * howBtn = (UIButton *)[cell searchViewWithTag:102];
    [[[howBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        if ([dict[@"title"] isEqualToString:@"发动机号"])
        {
//            @fq TODO
            [self showPicture:@"violation_eg"];
        }
        else
        {
            [self showPicture:@"violation_eg"];
        }
    }];
    
    // 副标题
    UILabel * subtitleLb = (UILabel *)[cell searchViewWithTag:103];
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
    OETextField * field = (OETextField *)[cell searchViewWithTag:104];
    [field setNormalInputAccessoryViewWithDataArr:@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"]];
    field.text = [dict objectForKey:@"no"];
    [dict safetySetObject:field forKey:@"feild"];
    
    
    field.placeholder = [NSString stringWithFormat:@"请输入%@%@",dict[@"title"],num ? [NSString stringWithFormat:@"后%ld位",(long)num]:@"全部"];

    [field setDidBeginEditingBlock:^(CKLimitTextField *field) {
        [MobClick event:@"rp901_4"];
    }];

    @weakify(self);
    [field setTextDidChangedBlock:^(CKLimitTextField *field) {

        @strongify(self);
        field.text = [field.text uppercaseString];
        
        if ([dict[@"title"] isEqualToString:@"发动机号"])
        {
            field.customTag = 1031;
            self.model.engineno = field.text;
            [dict safetySetObject:self.model.engineno forKey:@"no"];
        }
        else
        {
            field.customTag = 1032;
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
        if (!self.model.queryDate) {
            [MobClick event:@"rp901_2"];
        }
        else {
            [MobClick event:@"rp901_6"];
        }
        @strongify(self)
        if (!self.isQuerying)
        {
            [self queryAction];
        }
        else
        {
            [gToast showText:@"小马达达正在努力查询中\n请别着急"];
        }
    }];
    
    self.queryBtn = queryBtn;
    
    // 按钮下面的小标题
    UILabel * subtitleLb = (UILabel *)[cell searchViewWithTag:102];
    if (self.model.queryDate)
    {
        NSString * str = [NSString stringWithFormat:@"您于%@更新了%ld条信息",[self.model.queryDate dateFormatForYYYYMMddHHmmss],(unsigned long)self.model.violationArray.count];
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
