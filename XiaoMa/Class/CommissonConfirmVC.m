//
//  CommissonConfirmVC.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/17.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "CommissonConfirmVC.h"
#import "GetRescueHostCountsOp.h"
#import "GetRescueApplyHostCarOp.h"
#import "DatePickerVC.h"
#import "CarListVC.h"
#import "CommissionForsuccessfulVC.h"
#import "MyCarStore.h"
#import "WebVC.h"
#import "UIView+Layer.h"
#import "HKTableViewCell.h"


#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
@interface CommissonConfirmVC ()<UINavigationControllerDelegate, UIAlertViewDelegate>
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

@implementation CommissonConfirmVC
- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"CommissonConfirmVC dealloc~");
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.helperBtn];
    [self setupCarStore];
    //[self addSubView];
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
    [MobClick event:@"rp802-2"];
    self.tableView.backgroundColor = [UIColor colorWithRed:153 green:153 blue:153 alpha:1.0];
    if ([self.appointmentDay timeIntervalSinceDate:[NSDate date]] < 3600 * 24 * 1 - 1) {
        [self.underlyingView addSubview:self.alertV];
        [self.view addSubview:self.underlyingView];
        self.view.backgroundColor = [UIColor colorWithRed:153 green:153 blue:153 alpha:1.0];
        self.view.backgroundColor = [UIColor blueColor];
        
        UITapGestureRecognizer * recognizerTap = [[UITapGestureRecognizer alloc] init];
        [[recognizerTap rac_gestureSignal] subscribeNext:^(id x) {
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


- (void)actionAssisting{
    GetRescueApplyHostCarOp *op = [GetRescueApplyHostCarOp operation];
    op.licenseNumber = self.defaultCar.licencenumber;
    
    NSString *tempStr = [NSString stringWithFormat:@"%@", self.appointmentDay];
    if (tempStr.length >= 10) {
        op.appointTime = [tempStr substringToIndex:10];
    }else {
        op.appointTime = @"";
    }
    
    [[[[op rac_postRequest] initially:^{
        
    }] finally:^{
        
        
    }] subscribeNext:^(GetRescueApplyHostCarOp *op) {
        
        CommissionForsuccessfulVC *vc = [commissionStoryboard instantiateViewControllerWithIdentifier:@"CommissionForsuccessfulVC"];
        vc.licenceNumber = self.defaultCar.licencenumber;
        vc.timeValue = self.appointmentDay;
        [self.navigationController pushViewController:vc animated:YES];
        
    } error:^(NSError *error) {
        if (error.code == 611139001) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您还没有协办券哦，点击省钱攻略，此等优惠岂能错过！" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"省钱攻略", nil];
            [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *n) {
                NSInteger i = [n integerValue];
                if (i == 1) {
                    WebVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"WebVC"];
                    vc.title = @"省钱攻略";
                    vc.url = kMoneySavingStrategiesUrl;
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                    
                }
            }];
            [alert show];
        }else if (error.code == 0){
            CommissionForsuccessfulVC *vc = [commissionStoryboard instantiateViewControllerWithIdentifier:@"CommissionForsuccessfulVC"];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (error.code == 611139002) {
            
            [gToast showText:@"您的车辆已成功预约年检协办业务，详情可点击协办记录查看"];
        }else if (error.code == -1){
            [gToast showText:@"申请失败, 请尝试重新提交!"];
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
        CarListVC *vc = [UIStoryboard vcWithId:@"CarListVC" inStoryboard:@"Car"];
        vc.title = @"选择爱车";
        vc.model.allowAutoChangeSelectedCar = YES;
        vc.model.disableEditingCar = YES;
        vc.model.currentCar = self.defaultCar;
        vc.model.originVC = self;
        [vc.model setFinishBlock:^(HKMyCar *curSelectedCar) {
            self.defaultCar = curSelectedCar;
            [self countNetwork];
        }];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (indexPath.row == 4){
        DatePickerVC *vc = [DatePickerVC datePickerVCWithMaximumDate:[self getPriousorLaterDateFromDate:[NSDate date] withMonth:12]];
        vc.minimumDate = [NSDate date];
        [[vc rac_presentPickerVCInView:self.navigationController.view withSelectedDate:[NSDate date]]
         subscribeNext:^(NSDate *date) {
             self.appointmentDay = date;
             [self.tableView reloadData];
         }];
    }
}

#pragma mark - month
-(NSDate *)getPriousorLaterDateFromDate:(NSDate *)date withMonth:(int)month

{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    [comps setMonth:month];
    
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDate *mDate = [calender dateByAddingComponents:comps toDate:date options:0];
    
    return mDate;
    
}
#pragma mark - Lazy

- (NSDate *)appointmentDay {
    if (!_appointmentDay) {
        self.appointmentDay = [[NSDate alloc] init];
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
        _helperBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
        
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
        self.underlyingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
        self.underlyingView.backgroundColor = [UIColor redColor];
        self.underlyingView.backgroundColor = [UIColor colorWithRed:248 green:124 blue:128 alpha:0.5];
    }
    return _underlyingView;
}
- (UIView *)alertV {
    
    if (!_alertV) {
        
        self.alertV = [[UIView alloc] initWithFrame:CGRectMake((kWidth-270)/2, (kHeight - 180)/2 - 30, 270, 150)];
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
        self.titleLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 270, 30)];
        _titleLb.text = @"预约协办";
        _titleLb.textAlignment = NSTextAlignmentCenter;
        _titleLb.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    }
    return _titleLb;
}

- (UILabel *)detailLb {
    if (!_detailLb) {
        self.detailLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, 270, 40)];
        _detailLb.text = @"您将预约年检协办业务, 再告诉你个秘密,\n电话预约会更及时有效哦!";
        _detailLb.textAlignment = NSTextAlignmentCenter;
        _detailLb.numberOfLines = 0;
        _detailLb.font = [UIFont systemFontOfSize:12];
        
    }
    return _detailLb;
}

- (UIButton *)commissionBtn {
    if (!_commissionBtn) {
        self.commissionBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _commissionBtn.frame = CGRectMake(0, 102, 134, 49);
        [_commissionBtn setTitle:@"立即协办" forState:UIControlStateNormal];
        _commissionBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
        
        [[_commissionBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [self actionAssisting];
            [self.underlyingView removeFromSuperview];
        }];
        
    }
    return _commissionBtn;
}

- (UIButton *)phoneBtn {
    if (!_phoneBtn) {
        self.phoneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _phoneBtn.frame = CGRectMake(136, 102, 134, 49);
        [_phoneBtn setTitle:@"拨打电话" forState:UIControlStateNormal];
        _phoneBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
        [[_phoneBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
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
        self.horizontalLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 101, 270, 0.5)];
        _horizontalLineView.backgroundColor = [UIColor colorWithHex:@"#e3e3e3" alpha:1.0];
    }
    return _horizontalLineView;
}

- (UIView *)verticalLineView {
    if (!_verticalLineView) {
        self.verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(135, 100, 0.5, 48)];
        _verticalLineView.backgroundColor = [UIColor colorWithHex:@"#e3e3e3" alpha:1.0];
    }
    return _verticalLineView;
}
- (void)addSubView {
    [self.alertV addSubview:self.titleLb];
    [self.alertV addSubview:self.detailLb];
    [self.alertV addSubview:self.commissionBtn];
    [self.alertV addSubview:self.phoneBtn];
    [self.alertV addSubview:self.horizontalLineView];
    [self.alertV addSubview:self.verticalLineView];
}


@end
