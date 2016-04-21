//
//  RescueHomeViewController.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/9.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "RescueHomeViewController.h"
#import "RescueHistoryViewController.h"
#import "GetRescueOp.h"
#import "RescueDetailsVC.h"
#import "HKRescue.h"
#import "GetRescueNoLoginOp.h"
#import "HKRescueNoLogin.h"
#import "RescueApplyOp.h"
#import "ADViewController.h"
#import "UIView+DefaultEmptyView.h"
#import "UIView+JTLoadingView.h"
#import "NSDate+DateForText.h"
#import "NSString+RectSize.m"
#import "NSString+RectSize.h"


#define kWidth [UIScreen mainScreen].bounds.size.width
@interface RescueHomeViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView    * tableView;
@property (weak, nonatomic) IBOutlet UIView         * bottomView;
@property (weak, nonatomic) IBOutlet UILabel        * addressLb;
@property (nonatomic ,strong) UIButton      * historyBtn;
@property (nonatomic, strong) ADViewController  * adctrl;
@property (nonatomic, strong) NSMutableArray    * datasourceArray;
@property (nonatomic, strong) NSMutableArray    * desArray;
@end

@implementation RescueHomeViewController

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"RescueHomeViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    // [self addsubView];
    [self requestGetAddress];
    
    @weakify(self)
    [[RACObserve(gAppMgr, myUser) distinctUntilChanged] subscribeNext:^(id x) {
        @strongify(self)
        [self actionFirstEnterNetwork];
    }];
    
}


#pragma mark - SetupUI
- (void)setupUI
{
    UIView * headerView = (UIView *)[self.tableView searchViewWithTag:1111];
    headerView.frame = CGRectMake(0, 0, kWidth, 0.44 * kWidth + 38 + 13);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.historyBtn];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 28)];
    
}


#pragma mark - Action
- (void)requestGetAddress {
    RACSignal *sig1 = [[gMapHelper rac_getInvertGeoInfo] take:1];
    
    @weakify(self)
    [[sig1 initially:^{
     @strongify(self)
        self.addressLb.text = @"定位中...";
    }] subscribeNext:^(AMapReGeocode *regeo) {
        @strongify(self)
        gMapHelper.addrComponent = [HKAddressComponent addressComponentWith:regeo.addressComponent];
        
        CGFloat lbWidth = gAppMgr.deviceInfo.screenSize.width - 57;
        CGFloat textWidth = [regeo.formattedAddress labelSizeWithWidth:FLT_MAX font:[UIFont systemFontOfSize:12]].width;
        /// 如果超过label大小
        if (textWidth > lbWidth)
        {
            NSString *tempAdd = [NSString stringWithFormat:@"%@%@%@%@",
                                 regeo.addressComponent.district,
                                 regeo.addressComponent.township,
                                 regeo.addressComponent.streetNumber.street,
                                 regeo.addressComponent.streetNumber.number];
            self.addressLb.text = [tempAdd stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        }
        else
        {
            self.addressLb.text = regeo.formattedAddress;
        }

    } error:^(NSError *error) {
        @strongify(self)
        switch (error.code) {
            case kCLErrorDenied:
            {
                if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
                {
                    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:HEXCOLOR(@"#888888") clickBlock:nil];
                    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"前往设置" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }];
                    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb" Message:@"请允许小马达达访问您的位置，进入系统-[设置]-[小马达达]-[位置]-使用期间" ActionItems:@[cancel,confirm]];
                    [alert show];
                    
                }
                else
                {
                    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:HEXCOLOR(@"#f39c12") clickBlock:nil];
                    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb" Message:@"请允许小马达达访问您的位置" ActionItems:@[cancel]];
                    [alert show];
                    
                }
                break;
            }
            case LocationFail:
            {
                HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#f39c12") clickBlock:nil];
                HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"城市定位失败,请重试" ActionItems:@[cancel]];
                [alert show];
            }
            default:
            {
                
                self.addressLb.text = @"获取位置失败, 请尝试\"刷新\"";
                break;
            }
        }
    }];
}
- (void)actionFirstEnterNetwork {
    [self.datasourceArray removeAllObjects];
    [self.desArray removeAllObjects];
    
    @weakify(self)
    
    if (gAppMgr.myUser != nil)
    {//已登录
        GetRescueOp *op = [GetRescueOp operation];
        [[[op rac_postRequest] initially:^{
            @strongify(self)
            [self.view hideDefaultEmptyView];
            [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        }] subscribeNext:^(GetRescueOp *op) {
            @strongify(self)
            [self.view stopActivityAnimation];
            [self.datasourceArray safetyAddObjectsFromArray:op.rsp_resceuArray];
            NSString *tempStr;
            NSString *lastStr;
            for (HKRescue *rescue in op.rsp_resceuArray)
            {
                tempStr = [NSString stringWithFormat:@"● %@", rescue.rescueDesc];
                lastStr = [tempStr stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n● "];
                [self.desArray safetyAddObject:lastStr];
            }
            [self.tableView reloadData];
        } error:^(NSError *error) {
            @strongify(self)
            [self.view stopActivityAnimation];
        }] ;
    }
    else
    {//未登录
        GetRescueNoLoginOp *op = [GetRescueNoLoginOp operation];
        [[[op rac_postRequest] initially:^{
            @strongify(self)
            [self.view hideDefaultEmptyView];
            [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        }] subscribeNext:^(GetRescueNoLoginOp *op) {
            @strongify(self)
            [self.view stopActivityAnimation];
            [self.datasourceArray safetyAddObjectsFromArray:op.rsp_resceuArray];
            NSString *tempStr;
            NSString *lastStr;
            for (HKRescueNoLogin *rescue in op.rsp_resceuArray) {
                tempStr = [NSString stringWithFormat:@"● %@", rescue.rescueDesc];
                lastStr = [tempStr stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n● "];
                [self.desArray safetyAddObject:lastStr];
            }
            [self.tableView reloadData];
        } error:^(NSError *error) {
            @strongify(self)
            [self.view stopActivityAnimation];
        }] ;
    }
}
- (IBAction)actionAKeyRescue:(UIButton *)sender {
    /**
     *  一键救援事件
     */
    [MobClick event:@"rp701_2"];
    if (gAppMgr.myUser != nil) {
        RescueApplyOp *op = [RescueApplyOp operation];
        op.address = self.addressLb.text;
        op.longitude = [NSString stringWithFormat:@"%lf", gMapHelper.coordinate.longitude];
        op.latitude = [NSString stringWithFormat:@"%lf", gMapHelper.coordinate.latitude];
        
        [[[[op rac_postRequest] initially:^{
            
        }] finally:^{
            
        }] subscribeNext:^(RescueApplyOp *op) {
            
        } error:^(NSError *error) {
            
        }] ;
        NSString * number = @"4007111111";
        [gPhoneHelper makePhone:number andInfo:@"救援电话: 4007-111-111"];
    }else{
        NSString * number = @"4007111111";
        [gPhoneHelper makePhone:number andInfo:@"救援电话: 4007-111-111"];
    }
}

- (void)actionPhoneHelper:(UIButton *)sender {
    
}

- (void)actionRescueHistory {
    /**
     *  救援记录事件
     */
    [MobClick event:@"rp701_1"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        RescueHistoryViewController *vc = [rescueStoryboard instantiateViewControllerWithIdentifier:@"RescueHistoryViewController"];
        vc.type = 1;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)refreshClick:(UIButton *)sender {
    /**
     *  更新定位事件
     */
    [MobClick event:@"rp701_6"];
    [self requestGetAddress];
}

#pragma mark - spacing
- (NSAttributedString *)attributedStringforHeight:(NSString *)str {
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:str];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:3];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [str length])];
    return attributedString1;
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RescueHomeViewController" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *titleImg    = (UIImageView *)[cell searchViewWithTag:1000];
    UILabel * nameLb         = (UILabel *)[cell searchViewWithTag:1001];
    UILabel * conditionsLb   = (UILabel *)[cell searchViewWithTag:1006];
    UILabel * priceLb        = (UILabel *)[cell searchViewWithTag:1003];
    UILabel * numberLb       = (UILabel *)[cell searchViewWithTag:1004];
    UIView  * view           = (UIView  *)[cell searchViewWithTag:1005];
    UILabel * remainingLb    = (UILabel *)[cell searchViewWithTag:1007];
    UILabel * tempLb         = (UILabel *)[cell searchViewWithTag:1008];
    view.layer.borderColor = [UIColor colorWithHex:@"#fe9d87" alpha:1].CGColor;
    view.layer.cornerRadius = 4;
    view.layer.masksToBounds = YES;
    if (gAppMgr.myUser != nil) {
        HKRescue *rescue = [self.datasourceArray safetyObjectAtIndex:indexPath.row];
        nameLb.text = rescue.serviceName;
        priceLb.text = [NSString stringWithFormat:@"￥%@", rescue.amount];
        numberLb.text = [NSString stringWithFormat:@"%@", rescue.serviceCount];
        
        if ([rescue.serviceCount integerValue] == 0) {
            numberLb.hidden = YES;
            remainingLb.hidden = YES;
            tempLb.hidden = YES;
        }else {
            numberLb.hidden = NO;
            remainingLb.hidden = NO;
            tempLb.hidden = NO;
        }
        if (self.desArray.count != 0) {
            [conditionsLb setAttributedText:[self attributedStringforHeight:[self.desArray safetyObjectAtIndex:indexPath.row]]];
        }
        
    }else {
        HKRescueNoLogin *noLogin = self.datasourceArray[indexPath.row];
        nameLb.text = noLogin.serviceName;
        priceLb.text = [NSString stringWithFormat:@"￥%@", noLogin.amount];
        if (self.desArray.count != 0) {
            [conditionsLb setAttributedText:[self attributedStringforHeight:[self.desArray safetyObjectAtIndex:indexPath.row]]];
        }else{
            
        }
        numberLb.hidden = YES;
        remainingLb.hidden = YES;
        tempLb.hidden = YES;
    }
    
    if (indexPath.row == 0) {
        titleImg.image = [UIImage imageNamed:@"rescue_trailer"];
    }else if (indexPath.row == 1){
        titleImg.image = [UIImage imageNamed:@"pump_power"];
    }else if (indexPath.row == 2){
        titleImg.image = [UIImage imageNamed:@"rescue_tire"];
    }
    return cell;
}



#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * str = [self.desArray safetyObjectAtIndex:indexPath.row];
    
    CGFloat width = kWidth - 149;
    CGSize size = [str labelSizeWithWidth:width font:[UIFont systemFontOfSize:12]];
    if (size.height < 20) {
        return 89;
    }else if (size.height >= 20 && size.height <= 40) {
        return 89 ;
    }else {
        return 89 + size.height - 10;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (gAppMgr.myUser != nil) {
        /**
         *  三种救援点击事件
         */
        switch (indexPath.row)
        {
            case 0:
                [MobClick event:@"rp701_3"];
                break;
            case 1:
                [MobClick event:@"rp701_4"];
                break;
            default:
                [MobClick event:@"rp701_5"];
                break;
        }
        HKRescue *rescue = self.datasourceArray[indexPath.row];
        RescueDetailsVC *vc = [UIStoryboard vcWithId:@"RescueDetailsVC" inStoryboard:@"Rescue"];
        vc.type = rescue.type;
        
        vc.titleStr = rescue.serviceName;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else {
        HKRescueNoLogin *noLogin = self.datasourceArray[indexPath.row];
        RescueDetailsVC *vc = [UIStoryboard vcWithId:@"RescueDetailsVC" inStoryboard:@"Rescue"];
        vc.type = noLogin.type;
        vc.titleStr = noLogin.serviceName;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}


#pragma mark - lazyLoading
- (UIButton *)historyBtn {
    if (!_historyBtn) {
        self.historyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _historyBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _historyBtn.frame = CGRectMake(0, 0, 60, 44);
        [_historyBtn setTitle:@"救援记录" forState:UIControlStateNormal];
        [_historyBtn addTarget:self action:@selector(actionRescueHistory) forControlEvents:UIControlEventTouchUpInside];
    }
    return _historyBtn;
}

- (NSMutableArray *)datasourceArray {
    if (!_datasourceArray) {
        self.datasourceArray = [[NSMutableArray alloc] init];
    }
    return _datasourceArray;
}
- (NSMutableArray *)desArray {
    if (!_desArray) {
        self.desArray = [[NSMutableArray alloc] init];
    }
    return _desArray;
}
@end
