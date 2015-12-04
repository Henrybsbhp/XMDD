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
#import "AreaPickerVC.h"
#import "HKLocationDataModel.h"
#import "GetCityInfoByNameOp.h"



@interface ViolationItemViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)NSArray * infoArray;



/// 旋转动画
@property (nonatomic,weak)UIImageView * animationView;
@property (nonatomic,strong)CABasicAnimation * animation;
@property (nonatomic)BOOL isQuerying;
@property (nonatomic)CGFloat currentAngle;
/// 是否查询过，用于图片替换，和主逻辑关系不大
@property (nonatomic)BOOL isQueryed;


/// 是否展开
@property (nonatomic)BOOL isSpread;

/// 是否城市信息获取
@property (nonatomic)BOOL isCityLoading;

@end

@implementation ViolationItemViewController

- (void)dealloc
{
    DebugLog(@"ViolationItemViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    if (self.car)
    {
        [self setupData];
    }
    else
    {
        
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  Utility
- (void)setupUI
{
    self.isSpread = NO;
    
    NSInteger total = self.carArray.count + (self.carArray.count < 5 ? 1 : 0);
    NSInteger current = self.car ? [self.carArray indexOfObject:self.car] : self.carArray.count;
    self.pageControl.numberOfPages = total;
    self.pageControl.currentPage = current;
    self.pageControl.currentPageIndicatorTintColor =[UIColor redColor];
    self.pageControl.pageIndicatorTintColor =[UIColor yellowColor];

    
    /// 旋转动画
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 8.0f;
    rotationAnimation.repeatCount = FLT_MAX;
    rotationAnimation.cumulative = NO;
    
    self.animation = rotationAnimation;
}


- (void)setupData
{
    if (!self.model)
    {
        self.model = [[ViolationModel alloc] init];
        self.model.licencenumber = self.car.licencenumber;
        
        @weakify(self)
        [[self.model rac_getLocalUserViolation] subscribeNext:^(id x) {
            
            @strongify(self)
            [self handleViolationCityInfo];
            [self.tableView reloadData];
        }];
    }
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


#pragma mark - Utility
- (void)queryAction
{
    for (NSDictionary * dict in self.infoArray)
    {
        UITextField * feild = [dict objectForKey:@"feild"];
        NSInteger num = [dict[@"suffixno"] integerValue];
        if (feild.text.length < num && num > 0)
        {
            [feild.superview.subviews makeObjectsPerformSelector:@selector(shake)];
            return;
        }
        if (feild.text.length == 0)
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
            self.model.classno = feild.text;
        }
    }
    
    [self requesViolation];
}

- (void)requesViolation
{
    self.model.licencenumber = self.car.licencenumber;
    self.model.cid = self.car.carId;
    
    [[[[self.model rac_requestUserViolation] initially:^{
        
        self.isQuerying = YES;
        [self queryTransform];
    }] delay:3.0f] subscribeNext:^(id x) {
        
        self.isQuerying = NO;
        [self stopQueryTransform];
        self.isSpread = NO;
        [self.tableView reloadData];
    } error:^(NSError *error) {
    
        self.isQuerying = NO;
        [self stopQueryTransform];
        [self.tableView reloadData];
//        [gToast showError:error.domain];
    }];
}


- (void)queryTransform
{
    CFTimeInterval pausedTime = [self.animationView.layer timeOffset];
    self.animationView.layer.speed = 1.0;
    self.animationView.layer.timeOffset = 0.0;
    self.animationView.layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [self.animationView.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.animationView.layer.beginTime = timeSincePause;
}

- (void)stopQueryTransform
{
    CFTimeInterval pausedTime = [self.animationView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.animationView.layer.speed = 0.0;
    self.animationView.layer.timeOffset = pausedTime;
    
    CALayer* layer = [self.animationView.layer presentationLayer];
    self.currentAngle = [[layer valueForKeyPath:@"transform.rotation.z"] floatValue];
    
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
                height = 100;
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
                height = 100;
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
            
            if (!violation.customTag)
            {
                CGFloat width1 = gAppMgr.deviceInfo.screenSize.width - 54;
                CGSize size1 = [violation.violationArea labelSizeWithWidth:width1 font:[UIFont systemFontOfSize:12]];
                
                CGFloat width2 = gAppMgr.deviceInfo.screenSize.width - 40;
                CGSize size2 = [violation.violationAct labelSizeWithWidth:width2 font:[UIFont systemFontOfSize:15]];
                
                height = 60 + size1.height + 16 + size2.height + 14;
                violation.customTag = height;
            }
            height = violation.customTag;
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
        EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([cell.reuseIdentifier  isEqualToString:@"SeparatorCell"])
    {
        
        if (self.isSpread)
        {
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
        else
        {
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
    // 城市点击区域
    UIButton * cityBtn = (UIButton *)[cell searchViewWithTag:101];
    [cityBtn setTitle:self.model.cityInfo.cityName forState:UIControlStateNormal];
    cityBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [[[cityBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        NSArray * plistArr = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"area.plist" ofType:nil]];
        [[[[AreaPickerVC rac_presentPickerVCInView:self.view withDatasource:plistArr andCurrentValue:nil forStyle:AreaPickerWithStateAndCityAndDistrict] flattenMap:^RACStream *(HKLocationDataModel * locationData) {
           
            GetCityInfoByNameOp * op = [[GetCityInfoByNameOp alloc] init];
            op.province = @"浙江省";
            op.city = @"杭州市";
            return [op rac_postRequest];
        }] initially:^{
            
            self.isCityLoading = YES;
            ai.hidden = !self.isCityLoading;
            ai.animating = self.isCityLoading;
        }] subscribeNext:^(GetCityInfoByNameOp * op) {
            
            self.isCityLoading = NO;
            ai.hidden = !self.isCityLoading;
            ai.animating = self.isCityLoading;
            self.isSpread = YES;
            
            
            ViolationCityInfo * info = op.cityInfo;
            self.model.cityInfo = info;
        
            [self handleViolationCityInfo];
            [self.tableView reloadData];
        } error:^(NSError *error) {
            
            self.isCityLoading = NO;
            ai.hidden = !self.isCityLoading;
            ai.animating = self.isCityLoading;
            [gToast showError:error.domain];
        }];

    }];
    
    
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
        subtitleLb.text = [NSString stringWithFormat:@"后%ld位",(long)num];
    }
    else
    {
        subtitleLb.text = [NSString stringWithFormat:@"全填"];
    }
    
    //输入框
    UITextField * feild = (UITextField *)[cell searchViewWithTag:103];
    feild.text = [dict objectForKey:@"no"];
    [dict safetySetObject:feild forKey:@"feild"];
    
    return cell;
}

- (UITableViewCell *)searchBtnCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SearchBtnCell"];
    
    // 查询按钮
    UIButton * queryBtn = (UIButton *)[cell searchViewWithTag:101];
    [queryBtn setTitle:@"查询违章信息" forState:UIControlStateNormal || UIControlStateHighlighted];
    UIImageView * animationView = queryBtn.imageView;
    if (!self.model.queryDate && !self.isQueryed)
    {
        animationView.image = [UIImage imageNamed:@"search_white"];
    }
    else
    {
        animationView.image = [UIImage imageNamed:@"loading_white"];
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
    CALayer* layer = [animationView.layer presentationLayer];
    CGFloat angle = [[layer valueForKeyPath:@"transform.rotation.z"] floatValue];
    if (self.currentAngle != angle)
    {
//        animationView.layer.transform = CATransform3DMakeRotation(self.currentAngle,0.0f,0.0f,1.0f);
        animationView.transform = CGAffineTransformMakeRotation(self.currentAngle);
    }
    
    self.animationView = animationView;
        
    
    [[[queryBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        if (!self.isQuerying)
        {
            [self queryAction];
        }
        self.isQueryed = YES;
        
    }];
    
    // 按钮下面的小标题
    UILabel * subtitleLb = (UILabel *)[cell searchViewWithTag:102];
    if (self.model.queryDate)
    {
        if (self.model.violationArray.count)
        {
            NSString * str = [NSString stringWithFormat:@"于%@查到过%lu条违章信息，抓紧处理吧",[self.model.queryDate dateFormatForText],(unsigned long)self.model.violationArray.count];
            subtitleLb.text = str;
        }
        else
        {
            NSString * str = [NSString stringWithFormat:@"于%@查到过%lu条违章信息，继续保持",[self.model.queryDate dateFormatForText],(unsigned long)self.model.violationArray.count];
            subtitleLb.text = str;
        }
    }
    else
    {
        subtitleLb.text = @"您尚未查询过爱车违章";
    }

    return cell;
}

- (UITableViewCell *)violationTitleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ViolationTitleCell"];
    
    // 违章标题
    UILabel * titleLb = (UILabel *)[cell searchViewWithTag:101];
    titleLb.text = [NSString stringWithFormat:@"共扣%ld分，罚款%ld元",self.model.violationTotalfen,self.model.violationTotalmoney];
    
    return cell;
}

- (UITableViewCell *)violationItemCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ViolationItemCell"];
    
    HKViolation * violation = [self.model.violationArray safetyObjectAtIndex:indexPath.row - 1];
    
    ///罚款标志
    UILabel * moneyLb = (UILabel *)[cell searchViewWithTag:101];
    moneyLb.text = violation.violationMoney;
    
    ///罚分标志
    UILabel * fenLb = (UILabel *)[cell searchViewWithTag:102];
    fenLb.text = violation.violationScore;
    
    ///处理情况图标
    UIImageView * handleIcon = (UIImageView *)[cell searchViewWithTag:103];
    

    ///时间标志
    UILabel * whenLb = (UILabel *)[cell searchViewWithTag:104];
    whenLb.text = [violation.violationDate dateFormatForText];
    
    ///地点标志
    UILabel * whereLb = (UILabel *)[cell searchViewWithTag:105];
    whereLb.text = violation.violationArea;
    
    ///原因标志
    UILabel * whyLb = (UILabel *)[cell searchViewWithTag:106];
    whyLb.text = violation.violationAct;
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
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
        
        // 如何填写的事件
    }];
    return cell;
}

- (UITableViewCell *)separatorCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SeparatorCell"];
    return cell;
}


@end
