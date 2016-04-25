//
//  CommissonConfirmVC.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/17.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "CommissionConfirmVC.h"
#import "GetRescueHostCountsOp.h"
#import "GetRescueApplyHostCarOp.h"
#import "DatePickerVC.h"
#import "PickCarVC.h"
#import "CommissionSuccessVC.h"
#import "MyCarStore.h"
#import "DetailWebVC.h"
#import "UIView+Layer.h"
#import "HKTableViewCell.h"
#import "NSDate+DateForText.h"


#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
@interface CommissionConfirmVC ()<UINavigationControllerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy)     NSString    * licenseNumber;
@property (nonatomic, strong)   NSDate      * appointmentDay;
@property (nonatomic, strong)   UIView      * bottomView;
@property (nonatomic, strong)   UIButton    * helperBtn;
@property (nonatomic, strong)   MyCarStore  * carStore;
@property (nonatomic, strong)   HKMyCar     * defaultCar;
@property (nonatomic, strong)   NSString    * countStr;
/**
 *  alertView
 */
@property (nonatomic, strong)   UIView      * underlyingView;
@property (nonatomic, strong)   UIView      * alertV;
@property (nonatomic, strong)   UILabel     * titleLb;
@property (nonatomic, strong)   UILabel     * detailLb;
@property (nonatomic, strong)   UIButton    * commissionBtn;
@property (nonatomic, strong)   UIButton    * phoneBtn;
@property (nonatomic, strong)   UIView      * horizontalLineView;
@property (nonatomic, strong)   UIView      * verticalLineView;

@end

@implementation CommissionConfirmVC
- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"CommissonConfirmVC dealloc~");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.underlyingView removeSubviews];
    [self.underlyingView removeFromSuperview];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.helperBtn];
    [self setupCarStore];
    [self setupUI];
}


#pragma mark - Action
- (void) countNetwork {
    GetRescueHostCountsOp *op = [GetRescueHostCountsOp operation];
    op.licenseNumber = self.defaultCar.licencenumber;
    @weakify(self)
    [[[[op rac_postRequest] initially:^{
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        
    }] finally:^{
        [self.view stopActivityAnimation];
    }] subscribeNext:^(GetRescueHostCountsOp *op) {
        @strongify(self)
        self.countStr = [NSString stringWithFormat:@"%@", op.counts];
        if ([op.counts integerValue] == 0) {
            [gToast showText:@"当前车辆无协办券可用,请尝试其他车辆"];
        }
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
    }] ;
}

-(void)applyClick {
    /**
     *  开始协办点击事件
     */
    [MobClick event:@"rp802_2"];
    self.tableView.backgroundColor = [UIColor colorWithRed:153 green:153 blue:153 alpha:1.0];
    if ([self.appointmentDay timeIntervalSinceDate:[NSDate date]] < 3600 * 24 * 1 - 1) {
        [self.underlyingView addSubview:self.alertV];
        [self.view addSubview:self.underlyingView];
        self.view.backgroundColor = [UIColor colorWithRed:153 green:153 blue:153 alpha:1.0];
        self.view.backgroundColor = [UIColor blueColor];
        
        UITapGestureRecognizer * recognizerTap = [[UITapGestureRecognizer alloc] init];
        @weakify(self)
        [[recognizerTap rac_gestureSignal] subscribeNext:^(id x) {
            @strongify(self)
            if (recognizerTap.state == UIGestureRecognizerStateEnded){
                [self.underlyingView removeFromSuperview];
            }
        }];
        [recognizerTap setNumberOfTapsRequired:1];
        recognizerTap.cancelsTouchesInView = YES;
        [self.underlyingView addGestureRecognizer:recognizerTap];
    }else if ([self.appointmentDay timeIntervalSinceDate:[NSDate date]] > 3600 * 24 * 30) {
        [gToast showText:@"不好意思,预约时间需在 30 天内,请修改后再尝试"];
    } else {
        [self actionAssisting];
    }
}


- (void)actionAssisting
{
    GetRescueApplyHostCarOp *op = [GetRescueApplyHostCarOp operation];
    NSString * tempStr = [self.appointmentDay dateFormatForD10];
    op.appointTime = tempStr;
    op.licenseNumber = self.defaultCar.licencenumber;
    
    
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"申请中..." inView:self.view];
    }] subscribeNext:^(GetRescueApplyHostCarOp *op) {
        
        [gToast dismissInView:self.view];
        CommissionSuccessVC *vc = [commissionStoryboard instantiateViewControllerWithIdentifier:@"CommissionSuccessVC"];
        vc.licenceNumber = self.defaultCar.licencenumber;
        vc.timeValue = self.appointmentDay;
        [self.navigationController pushViewController:vc animated:YES];
        
    } error:^(NSError *error) {
        [gToast dismissInView:self.view];
        if (error.code == 611139001) {
//            
//            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:^(id alertVC) {
//                
//            }];
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
            HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"省钱攻略" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
                vc.title = @"省钱攻略";
                vc.url = kMoneySavingStrategiesUrl;
                [self.navigationController pushViewController:vc animated:YES];
            }];
            HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:error.domain ActionItems:@[cancel,confirm]];
            [alert show];
            
        }
        else if (error.code == 611139002)
        {
            
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"协办结果" ImageName:@"mins_bulb" Message:error.domain ActionItems:@[cancel]];
            [alert show];
            
        }
        else
        {
            [gToast showError:error.domain];
        }
    }] ;
}

- (void)setupCarStore
{
    self.carStore = [MyCarStore fetchOrCreateStore];
    @weakify(self);
    [self.carStore subscribeWithTarget:self domain:@"cars" receiver:^(CKStore *store, CKEvent *evt) {
        
        @strongify(self);
        [[evt signal] subscribeNext:^(id x) {
            @strongify(self);
            if (!self.defaultCar)
            {
                self.defaultCar = [self.carStore defalutCar];
                [self countNetwork];
                
            }
        }];
    }];
    [[self.carStore getAllCarsIfNeeded] send];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UITableViewCell *cell3 = [tableView dequeueReusableCellWithIdentifier:@"CommissonConfirmVC3"];
        return cell3;
    }else if (indexPath.row ==1 || indexPath.row == 2) {
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"CommissonConfirmVC1"];
        UILabel *titleLb = (UILabel *)[cell1 searchViewWithTag:1000];
        UILabel *detailLb = (UILabel *)[cell1 searchViewWithTag:1001];
        if (indexPath.row == 1) {
            titleLb.text = @"申请服务";
            detailLb.text = @"年检协办";
        }else if (indexPath.row == 2){
            titleLb.text = @"剩余协办";
            if (self.defaultCar != nil) {
                detailLb.textColor = [UIColor colorWithHex:@"#fe4a00" alpha:1.0];
                detailLb.text = [NSString stringWithFormat:@"%@次", self.countStr];
            }
        }
        
        return cell1;
        
    }else {
        UITableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"CommissonConfirmVC2"];
        UILabel *titleLb = (UILabel *)[cell2 searchViewWithTag:1002];
        UILabel *detailsLb = (UILabel *)[cell2 searchViewWithTag:1003];
        if (indexPath.row == 3) {
            titleLb.text = @"服务车辆";
            detailsLb.text = self.defaultCar.licencenumber;
        }else if (indexPath.row == 4){
            titleLb.text = @"预约时间";
            detailsLb.text = [self.appointmentDay dateFormatForYYMMdd2];
        }
        return cell2;
    }
    
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 56;
    }else {
        return 25;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        //选择爱车
        PickCarVC *vc = [UIStoryboard vcWithId:@"PickCarVC" inStoryboard:@"Car"];
        vc.defaultCar = self.defaultCar;
        @weakify(self);
        [vc setFinishPickCar:^(MyCarListVModel *carModel, UIView * loadingView) {
            @strongify(self);
            self.defaultCar = carModel.selectedCar;
            [self countNetwork];
        }];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (indexPath.row == 4){
        DatePickerVC *vc = [DatePickerVC datePickerVCWithMaximumDate:[self getPriousorLaterDateFromDate:[NSDate date] withDays:29]];
        vc.minimumDate = [self getPriousorLaterDateFromDate:[NSDate date] withDays:3];
        [[vc rac_presentPickerVCInView:self.navigationController.view withSelectedDate:[self getPriousorLaterDateFromDate:[NSDate date] withDays:3]]
         subscribeNext:^(NSDate *date) {
             self.appointmentDay = date;
             [self.tableView reloadData];
         }];
    }
}

#pragma mark - month
-(NSDate *)getPriousorLaterDateFromDate:(NSDate *)date withDays:(int)days

{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    [comps setDay:days];
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDate *mDate = [calender dateByAddingComponents:comps toDate:date options:0];

    return mDate;
    
}
#pragma mark - Lazy

- (NSDate *)appointmentDay {
    if (!_appointmentDay) {
        _appointmentDay = [self getPriousorLaterDateFromDate:[NSDate date] withDays:3];
    }
    return _appointmentDay;
}

- (UIButton *)helperBtn {
    if (!_helperBtn) {
        self.helperBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.view addSubview:self.helperBtn];
        [_helperBtn setTitle:@"开始协办" forState:UIControlStateNormal];
        [_helperBtn addTarget:self action:@selector(applyClick) forControlEvents:UIControlEventTouchUpInside];
        [_helperBtn setTintColor:[UIColor whiteColor]];
        _helperBtn.backgroundColor = [UIColor colorWithHex:@"#35cb68" alpha:1];
        _helperBtn.cornerRadius = 4;
        _helperBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        
        [_helperBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view).offset(10);
            make.right.mas_equalTo(self.view).offset(-10);
            make.bottom.mas_equalTo(self.view).offset(- 5);
            make.height.mas_offset(40);
        }];
    }
    return _helperBtn;
}

- (UIView *)underlyingView {
    if (!_underlyingView) {
        _underlyingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
        _underlyingView.backgroundColor = [UIColor colorWithHex:@"#454545" alpha:0.6f];
    }
    return _underlyingView;
}
- (UIView *)alertV {
    
    if (!_alertV) {
        _alertV = [[UIView alloc] initWithFrame:CGRectZero];
        [self.underlyingView addSubview:self.alertV];
        [_alertV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.underlyingView).offset((kWidth -270)/2);
            make.top.equalTo(self.underlyingView).offset((kHeight - 180)/2 - 30);
            make.size.mas_equalTo(CGSizeMake(270, 150));
        }];
        _alertV.backgroundColor = [UIColor whiteColor];
        _alertV.cornerRadius = 8;
        _alertV.layer.borderWidth = 0.2;
        _alertV.clipsToBounds = YES;
        _alertV.layer.borderColor = [UIColor colorWithHex:@"#454545" alpha:1.0].CGColor;
        
    }
    return _alertV;
}

- (UILabel *)titleLb {
    if (!_titleLb) {
        self.titleLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 270, 30)];
        _titleLb.text = @"预约协办";
        _titleLb.textAlignment = NSTextAlignmentCenter;
        _titleLb.font = [UIFont boldSystemFontOfSize:15];
    }
    return _titleLb;
}

- (UILabel *)detailLb {
    if (!_detailLb) {
        _detailLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 47, 270, 40)];
        _detailLb.text = @"您将预约年检协办业务, 再告诉你个秘密,\n电话预约会更及时有效哦!";
        _detailLb.textAlignment = NSTextAlignmentCenter;
        _detailLb.numberOfLines = 0;
        _detailLb.font = [UIFont systemFontOfSize:13];
        
    }
    return _detailLb;
}

- (UIButton *)commissionBtn {
    if (!_commissionBtn) {
        _commissionBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _commissionBtn.frame = CGRectMake(0, 102, 134, 49);
        [_commissionBtn setTitle:@"立即协办" forState:UIControlStateNormal];
        _commissionBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        
        @weakify(self)
        [[_commissionBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self)
            [self actionAssisting];
            [self.underlyingView removeFromSuperview];
        }];
        
    }
    return _commissionBtn;
}

- (UIButton *)phoneBtn {
    if (!_phoneBtn) {
        _phoneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _phoneBtn.frame = CGRectMake(136, 102, 134, 49);
        [_phoneBtn setTitle:@"拨打电话" forState:UIControlStateNormal];
        _phoneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        
        @weakify(self)
        [[_phoneBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self)
            NSString * number = @"4007111111";
            NSString * urlStr = [NSString stringWithFormat:@"tel://%@",number];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
            [self.underlyingView removeFromSuperview];
        }];
    }
    return _phoneBtn;
}

- (UIView *)horizontalLineView {
    if (!_horizontalLineView) {
        _horizontalLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 101, 270, 0.5)];
        _horizontalLineView.backgroundColor = [UIColor colorWithHex:@"#e3e3e3" alpha:1.0];
    }
    return _horizontalLineView;
}

- (UIView *)verticalLineView {
    if (!_verticalLineView) {
        _verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(135, 100, 0.5, 48)];
        _verticalLineView.backgroundColor = [UIColor colorWithHex:@"#e3e3e3" alpha:1.0];
    }
    return _verticalLineView;
}
- (void)setupUI {
    [self.alertV addSubview:self.titleLb];
    [self.alertV addSubview:self.detailLb];
    [self.alertV addSubview:self.commissionBtn];
    [self.alertV addSubview:self.phoneBtn];
    [self.alertV addSubview:self.horizontalLineView];
    [self.alertV addSubview:self.verticalLineView];
}


@end
