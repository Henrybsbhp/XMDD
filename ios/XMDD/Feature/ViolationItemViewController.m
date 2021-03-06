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
#import "EditCarVC.h"
#import "CarIDCodeCheckModel.h"
#import "CKLimitTextField.h"
#import "OETextField.h"
#import "ViolationDelegateMissionVC.h"
#import "DetailWebVC.h"

#define ClassNumberStr @"车架号码"
#define EngineNumberStr @"发动机号"


@interface ViolationItemViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

/// 旋转动画
@property (nonatomic,weak)UIButton * queryBtn;
@property (nonatomic,strong)CABasicAnimation * animation;
@property (nonatomic)BOOL isQuerying;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
@property (weak, nonatomic) IBOutlet UILabel *issueLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *issueViewHeight;
@property (nonatomic,strong)CKList * datasource;

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
    
    [self setupUI];
    
    if (self.car)
    {
        [self getLocalViolationInfoAndCityInfo];
    }
    else
    {
        [self setupDatasource];
        [self setupBottomView];
        [self setupIssueView];
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
    
    self.view.backgroundColor = kBackgroundColor;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.bottomBtn.backgroundColor = kOrangeColor;
    self.bottomBtn.layer.cornerRadius = 5.0f;
    self.bottomBtn.layer.masksToBounds = YES;
    [self.bottomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    @weakify(self)
    [[self.bottomBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        @strongify(self)
        [MobClick event:@"weizhangshouye" attributes:@{@"daiban":@"daiban"}];
        [self actionGotoViolationDelegateMissionVC];
    }];
    
    self.bottomViewConstraint.constant = 0;
}

- (void)setupBottomView
{
    @weakify(self)
    NSString * title = self.violationModel.violationAvailableTip;
    [self.bottomBtn setTitle:title forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.5f animations:^{
     
        @strongify(self)
        self.bottomViewConstraint.constant = self.violationModel.violationAvailableTip.length > 0 ? 64 : 0;
    }];
}

- (void)setupIssueView
{
    @weakify(self)
    self.issueLabel.text = self.violationModel.text;
    [UIView animateWithDuration:0.5f animations:^{
     
        @strongify(self)
        self.issueViewHeight.constant = self.violationModel.showIssue ? 0 : -35;
    }];
}

- (void)setupDatasource
{
    self.datasource = [CKList list];
    if (!self.car)
    {
        CKDict * dict = [self setupAddCarCell];
        self.datasource = $($(dict));
        return;
    }
    
    CKList * list = [[CKList alloc] init];
    
    if (!self.violationModel.cityInfo.isViolationAvailable)
    {
        CKDict * dict = [self setupUnavailableCell];
        [list addObject:dict forKey:nil];
    }
    else
    {
        [self handleViolationCityInfo:list];
        
        CKDict * searchBtnDict = [self setupSearchBtnCell];
        [list addObject:searchBtnDict forKey:nil];
    }
    
    [self.datasource addObject:list forKey:nil];
    
    CKList * list2 = [[CKList alloc] init];
    if (self.violationModel.violationArray.count)
    {
        CKDict * violationTitleDict = [self setupViolationTitleCell];
        [list2 addObject:violationTitleDict forKey:nil];
        
        for (HKViolation * v in self.violationModel.violationArray)
        {
            CKDict * violationItem = [self setupViolationItemCell:v];
            [list2 addObject:violationItem forKey:nil];
        }
    }
    else
    {
        /// 查询过
        if (self.violationModel.queryDate)
        {
            CKDict * noViolationDict = [self setupNoViolationCell];
            [list2 addObject:noViolationDict forKey:nil];
        }
    }
    [self.datasource addObject:list2 forKey:nil];
}


- (void)getLocalViolationInfoAndCityInfo
{
    
    @weakify(self)
    self.violationModel.licencenumber = self.car.licencenumber;
    
    RACSignal * localViolationSignal = [self.violationModel rac_getLocalUserViolation];
    RACSignal * cityInfoSignal = [self.violationModel rac_getCityInfoByLincenseNumber];
    
    RACSignal * combineSignal = [RACSignal combineLatest:@[localViolationSignal,cityInfoSignal]];
    
    [[combineSignal initially:^{
        
        @strongify(self)
        CGFloat reducingY = self.view.frame.size.height * 0.1056;
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:CGPointMake(self.view.center.x, self.view.center.y - reducingY)];
        self.tableView.hidden = YES;
    }] subscribeNext:^(id x) {
        
        @strongify(self)
        [self.view stopActivityAnimation];
        self.tableView.hidden = NO;
        
        [self setupDatasource];
        [self.tableView reloadData];
        
        [self setupIssueView];
        [self setupBottomView];
    } error:^(NSError *error) {
        
        @strongify(self)
        [self.view stopActivityAnimation];
        self.tableView.hidden = YES;
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:error.domain tapBlock:^{
            @strongify(self);
            [self getLocalViolationInfoAndCityInfo];
        }];
    }];
}

- (void)handleViolationCityInfo:(CKList *)list
{
    if (self.violationModel.cityInfo.isClassNum)
    {
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:@{@"title":ClassNumberStr,
                                                                                     @"suffixno":@(self.violationModel.cityInfo.classSuffixNum)}];
        CKDict * inputInfoDict = [self setupInputInfoCellWithInfoDict:dict];
        [list addObject:inputInfoDict forKey:nil];
    }
    if (self.violationModel.cityInfo.isEngineNum)
    {
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:@{@"title":EngineNumberStr,
                                                                                     @"suffixno":@(self.violationModel.cityInfo.engineSuffixNum)}];
        CKDict * inputInfoDict = [self setupInputInfoCellWithInfoDict:dict];
        [list addObject:inputInfoDict forKey:nil];
    }
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
    
    if (!self.violationModel.queryDate)
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



#pragma mark - Network
/// 请求违章
- (void)requesQueryViolation
{
    
    @weakify(self)
    self.violationModel.licencenumber = self.car.licencenumber;
    self.violationModel.cid = self.car.carId;
    
    [[[self.violationModel rac_requestUserViolation] initially:^{
        
        @strongify(self)
        self.isQuerying = YES;
        [self queryTransform];
    }] subscribeNext:^(id x) {
        
        @strongify(self)
        self.isQuerying = NO;
        [self stopQueryTransform];
        
        [self setupDatasource];
        [self.tableView reloadData];
        [self setupBottomView];
        [self setupIssueView];
    } error:^(NSError *error) {
        
        @strongify(self)
        self.isQuerying = NO;
        [self stopQueryTransform];
        [self.tableView reloadData];
        [gToast showError:error.domain];
    }];
}




#pragma mark - Action

- (IBAction)actionJumpToViolationDelegateWebVC:(id)sender
{
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.url = self.violationModel.link;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)acitonCloseIssue:(id)sender
{
    @weakify(self)
    self.issueViewHeight.constant = -35;
    [UIView animateWithDuration:0.5f animations:^{
        
        @strongify(self)
        [self.view layoutIfNeeded];
    }];
    self.violationModel.showIssue = NO;
    /// 点击过按钮后保存。避免下次进入还有消息
    [self.violationModel saveViolationModel];
}


- (void)queryAction
{
    [MobClick event:@"weizhangshouye" attributes:@{@"chaxun" : @"chaxun"}];
    if (!self.violationModel.cityInfo.isViolationAvailable)
    {
        [gToast showError:@"该城市暂不支持违章查询"];
        return;
    }
    
    if (self.violationModel.cityInfo.isClassNum)
    {
        if (self.violationModel.classno.length == 0)
        {
            [gToast showError:@"请输入车架号"];
            return;
        }
        else if (self.violationModel.cityInfo.classSuffixNum == 0)
        {
            if (self.violationModel.classno.length == 0)
            {
                [gToast showError:@"请输入车架号"];
                return;
            }
        }
        else if (self.violationModel.classno.length < self.violationModel.cityInfo.classSuffixNum)
        {
            [gToast showError:@"请输入满足位数的车架号"];
            return;
        }
        
        
    }
    
    if (self.violationModel.cityInfo.isEngineNum)
    {
        if (self.violationModel.engineno.length < self.violationModel.cityInfo.engineSuffixNum || self.violationModel.engineno.length == 0)
        {
            [gToast showError:@"请输入满足位数的发动机号"];
            return;
        }
    }
    
    [self requesQueryViolation];
}

- (void)actionGotoViolationDelegateMissionVC
{
    @weakify(self)
    ViolationDelegateMissionVC * vc = [UIStoryboard vcWithId:@"ViolationDelegateMissionVC" inStoryboard:@"Violation"];
    vc.licenceNumber = self.violationModel.licencenumber;
    vc.userCarID = self.car.carId;
    vc.router.userInfo = [CKDict dictWithCKDict:self.router.userInfo];
    vc.router.userInfo[kOriginRoute]= self.parentViewController.router;
    [vc setMissionSuccessBlock:^(NSString * tip) {
        
        @strongify(self)
        self.violationModel.violationAvailableTip = tip;
        [self setupBottomView];
        [self.violationModel saveViolationModel];
    }];
    [self.navigationController pushViewController:vc animated:YES];
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
    CKDict *item = self.datasource[indexPath.section][indexPath.row];
    CKCellGetHeightBlock block = item[kCKCellGetHeight];
    
    if (block) {
        return block(item, indexPath);
    }
    return 49;
}





- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.datasource[section] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, gAppMgr.deviceInfo.screenSize.width, 8)];
    view.backgroundColor = section == 0 ? [UIColor whiteColor] : kBackgroundColor;
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CKDict *item = self.datasource[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item[kCKCellID] forIndexPath:indexPath];
    CKCellPrepareBlock block = item[kCKCellPrepare];
    
    if (block) {
        block(item, cell, indexPath);
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CKDict *item = self.datasource[indexPath.section][indexPath.row];
    if (item[kCKCellSelected]) {
        ((CKCellSelectedBlock)item[kCKCellSelected])(item, indexPath);
    }
}

#pragma mark - AboutCell
///设置「违章不可用」Cell
- (CKDict *)setupUnavailableCell
{
    CKDict *cell = [CKDict dictWith:@{kCKItemKey: @"ViolationUnavailableCell", kCKCellID: @"ViolationUnavailableCell"}];
    cell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 240;
    });
    
    cell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UILabel * lb = [cell viewWithTag:102];
        lb.numberOfLines = 0;
        lb.text = @"您的车牌归属地暂未开通此服务\n我们正在努力开拓中，敬请期待";
    });
    
    return cell;
}

///设置「信息录入」Cell
- (CKDict *)setupInputInfoCellWithInfoDict:(NSDictionary *)dict
{
    @weakify(self)
    CKDict *cell = [CKDict dictWith:@{kCKItemKey: @"InfoInputCell", kCKCellID: @"InfoInputCell"}];
    cell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 40;
    });
    
    cell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UILabel * titleLb = (UILabel *)[cell searchViewWithTag:101];
        titleLb.text = dict[@"title"];
        
        @strongify(self)
        UIButton * howBtn = (UIButton *)[cell searchViewWithTag:102];
        [[[howBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            @strongify(self)
            if ([dict[@"title"] isEqualToString:EngineNumberStr])
            {
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
        [field setNormalInputAccessoryViewWithDataArr:@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"]];
        
        
        field.placeholder = [NSString stringWithFormat:@"请输入%@%@",dict[@"title"],num ? [NSString stringWithFormat:@"后%ld位",(long)num]:@"全部"];
        
        if ([dict[@"title"] isEqualToString:ClassNumberStr])
        {
            [[RACObserve(self.violationModel,classno) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSString * x) {
                
                field.text = x;
            }];
        }
        
        if ([dict[@"title"] isEqualToString:EngineNumberStr])
        {
            [[RACObserve(self.violationModel,engineno) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                
                field.text = x;
            }];
        }
        
        [field setTextDidChangedBlock:^(CKLimitTextField *field) {
            
            @strongify(self)
            field.text = [field.text uppercaseString];
            
            if ([dict[@"title"] isEqualToString:EngineNumberStr])
            {
                self.violationModel.engineno = field.text;
            }
            else
            {
                self.violationModel.classno = field.text;
            }
        }];
    });
    
    return cell;
}

///设置「添加爱车」Cell
- (CKDict *)setupAddCarCell
{
    
    @weakify(self)
    CKDict *cell = [CKDict dictWith:@{kCKItemKey: @"AddCarCell", kCKCellID: @"AddCarCell"}];
    cell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 260;
    });
    
    cell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self)
        [MobClick event:@"weizhangshouye" attributes:@{@"tianjiaaiche" : @"tianjiaaiche"}];
        EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
        [self.navigationController pushViewController:vc animated:YES];
    });
    
    
    return cell;
}

///设置「搜索按钮」Cell
- (CKDict *)setupSearchBtnCell
{
    @weakify(self)
    CKDict *cell = [CKDict dictWith:@{kCKItemKey: @"SearchBtnCell", kCKCellID: @"SearchBtnCell"}];
    cell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 120;
    });
    
    
    cell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self)
        // 查询按钮
        UIButton * queryBtn = (UIButton *)[cell searchViewWithTag:101];
        [queryBtn setTitle:@"查询违章信息" forState:UIControlStateNormal || UIControlStateHighlighted];
        UIImageView * animationView = queryBtn.imageView;
        if (!self.violationModel.queryDate)
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
        
        [[[queryBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            @strongify(self)
            if (!self.violationModel.queryDate) {
                [MobClick event:@"weizhangshouye" attributes:@{@"chaxun" : @"1"}];
            }
            else {
                [MobClick event:@"weizhangshouye" attributes:@{@"chaxun" : @"0"}];
            }
            
            if (!self.isQuerying)
            {
                [self queryAction];
            }
            else
            {
                [MobClick event:@"weizhangshouye" attributes:@{@"chaxun" : @"chaxunzhongdianji"}];
                [gToast showText:@"小马达达正在努力查询中\n请别着急"];
            }
        }];
        
        self.queryBtn = queryBtn;
        
        // 按钮下面的小标题
        UILabel * subtitleLb = (UILabel *)[cell searchViewWithTag:102];
        subtitleLb.numberOfLines = 0;
        if (self.violationModel.queryDate)
        {
            NSString * str = [NSString stringWithFormat:@"您于%@更新了%ld条信息",[self.violationModel.queryDate dateFormatForYYYYMMddHHmmss],(unsigned long)self.violationModel.violationArray.count];
            subtitleLb.text = str;
        }
        else
        {
            subtitleLb.text = @"暂无更新信息";
        }
        
    });
    
    return cell;
}

///设置「鼓励」Cell
- (CKDict *)setupViolationTitleCell
{
    @weakify(self)
    CKDict *cell = [CKDict dictWith:@{kCKItemKey: @"ViolationTitleCell", kCKCellID: @"ViolationTitleCell"}];
    cell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 50;
    });
    
    cell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self)
        // 违章标题
        UILabel * titleLb = (UILabel *)[cell searchViewWithTag:101];
        titleLb.text = [NSString stringWithFormat:@"罚款%ld元，共扣%ld分",(long)self.violationModel.violationTotalmoney,(long)self.violationModel.violationTotalfen];
    });
    
    return cell;
}

///设置「违章标题」Cell
- (CKDict *)setupNoViolationCell
{
    CKDict *cell = [CKDict dictWith:@{kCKItemKey: @"NoViolationCell", kCKCellID: @"NoViolationCell"}];
    cell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 240;
    });
    
    return cell;
}

///设置「违章内容」Cell
- (CKDict *)setupViolationItemCell:(HKViolation *)violation
{
    CKDict *cell = [CKDict dictWith:@{kCKItemKey: @"ViolationItemCell", kCKCellID: @"ViolationItemCell"}];
    cell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        
        CGFloat width1 = gAppMgr.deviceInfo.screenSize.width - 60;
        CGSize size1 = [violation.violationArea labelSizeWithWidth:width1 font:[UIFont systemFontOfSize:12]];
        
        CGFloat width2 = gAppMgr.deviceInfo.screenSize.width - 45;
        CGSize size2 = [violation.violationAct labelSizeWithWidth:width2 font:[UIFont systemFontOfSize:15]];
        
        CGFloat height = 63 + size1.height + 16 + size2.height + 14;
        return height;
    });
    
    
    cell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        ///罚款标志
        UILabel * moneyLb = (UILabel *)[cell searchViewWithTag:20101];
        moneyLb.text = violation.violationMoney.length ? [NSString stringWithFormat:@"罚款%@元",violation.violationMoney] : @"罚款未知";
        
        ///罚分标志
        UILabel * fenLb = (UILabel *)[cell searchViewWithTag:20201];
        fenLb.text = violation.violationScore.length ? [NSString stringWithFormat:@"扣%@分",violation.violationScore] : @"扣分未知";
        
        ///处理情况图标
        UIImageView * handleIcon = (UIImageView *)[cell searchViewWithTag:103];
        
        ///时间标志
        UILabel * whenLb = (UILabel *)[cell searchViewWithTag:104];
        whenLb.text = violation.violationDate;
        
        ///地点标志
        UILabel * whereLb = (UILabel *)[cell searchViewWithTag:105];
        whereLb.numberOfLines = 0;
        whereLb.text = violation.violationArea;
        
        ///原因标志
        UILabel * whyLb = (UILabel *)[cell searchViewWithTag:106];
        whyLb.numberOfLines = 0;
        whyLb.text = violation.violationAct;
        
        if ([violation.ishandled isEqualToString:@"1"])
        {
            handleIcon.image = [UIImage imageNamed:@"handle_icon_300"];
        }
        else
        {
            handleIcon.image = [UIImage imageNamed:@"unhandle_icon_300"];
        }
    });
    
    cell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        NSString * mobClickValue = [NSString stringWithFormat:@"dianji_%ld",indexPath.row];
        [MobClick event:@"weizhangshouye" attributes:@{@"weizhangxinxin":mobClickValue}];
    });
    
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

#pragma mark - Lazy
- (ViolationModel *)violationModel
{
    if (!_violationModel)
    {
        _violationModel = [[ViolationModel alloc] init];
    }
    return _violationModel;
}

@end
