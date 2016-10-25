//
//  RescueHomeV2VC.m
//  XMDD
//
//  Created by St.Jimmy on 17/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import "RescueHomeV2VC.h"
#import "RescuePaymentStatusVC.h"
#import "RescueRecordVC.h"
#import "NSString+RectSize.h"

@interface RescueHomeV2VC ()
@property (weak, nonatomic) IBOutlet MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *addressSearch;

@property (nonatomic, strong) AMapReGeocodeSearchRequest *reqGEO;

@property (weak, nonatomic) IBOutlet UIView *addressView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (nonatomic) CLLocationCoordinate2D userCoordinate;
@property (nonatomic) BOOL needUpdateLocation;

@end

@implementation RescueHomeV2VC

- (void)dealloc
{
    self.mapView.delegate = nil;
    self.addressSearch.delegate = nil;
    DebugLog(@"RescueHomeV2VC is deallocated");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.needUpdateLocation = YES;
    [self setupMapView];
    [self setupAddressSearch];
    [self setupCenterCoordinateImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
/// 定位按钮点击事件
- (IBAction)actionLocateMyLocation:(id)sender
{
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}

/// 我的救援点击事件
- (IBAction)actionMyRescue:(id)sender
{
    RescueRecordVC *vc = [UIStoryboard vcWithId:@"RescueRecordVC" inStoryboard:@"Rescue"];
    [self.navigationController pushViewController:vc animated:YES];
}

/// 一键救援点击事件
- (IBAction)actionRescue:(id)sender
{
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#F39C12") clickBlock:^(id alertVC) {
        [gPhoneHelper makePhone:@"4007111111"];
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"救援电话：4007-111-111" ActionItems:@[cancel, confirm]];
    [alert show];
}

#pragma mark - Initial Setup
/// 设置中心坐标图案
- (void)setupCenterCoordinateImage
{
    UIImageView *coordinateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 27, 40)];
    coordinateImageView.image = [UIImage imageNamed:@"rescue_coordiate"];
    [self.mapView addSubview:coordinateImageView];
    @weakify(self);
    [coordinateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerX.equalTo(self.mapView);
        make.centerY.equalTo(self.mapView).offset(-30);
    }];
}

/// 设置 mapView
- (void)setupMapView
{
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    [self.mapView bringSubviewToFront:self.addressView];
}

/// 设置反地理编码的代理和请求
- (void)setupAddressSearch
{
    self.addressSearch = [[AMapSearchAPI alloc] init];
    self.addressSearch.delegate = self;
    self.reqGEO = [[AMapReGeocodeSearchRequest alloc] init];
}

#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    self.userCoordinate = userLocation.coordinate;
    if (self.needUpdateLocation) {
        [self setCenter:self.userCoordinate];
        self.needUpdateLocation = NO;
    }
}

- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction
{
    DebugLog(@"coordinate is: %f ---- %f", mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude);
    // 获取移动位置的坐标并做反地理编码
    self.reqGEO.location = [AMapGeoPoint locationWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
    self.reqGEO.requireExtension = YES;
    [self.addressSearch AMapReGoecodeSearch:self.reqGEO];
}

#pragma mark - AMapSearchDelegate
/// 反地理编码用到的回调代理
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    DebugLog(@"address title: %@", response.regeocode.formattedAddress);
    // 获取到格式化后的地址并赋值
    [self setAddressLabelText:[self stringByAppendingAddressStringWithSearchResponse:response]];
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    [gToast showMistake:@"位置获取失败"];
    [self setAddressLabelText:@"救援位置获取失败"];
}

#pragma mark - tools
- (void)setCenter:(CLLocationCoordinate2D)coordinate
{
    [self.mapView setZoomLevel:MapZoomLevel animated:YES];
    [self.mapView setCenterCoordinate:coordinate animated:YES];
}

- (void)setAddressLabelText:(NSString *)addressString
{
    self.addressLabel.text = [NSString stringWithFormat:@"救援位置：%@", addressString];
    CGSize labelSize = [self.addressLabel.text labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 67 font:[UIFont systemFontOfSize:14]];
    CGFloat height = MAX(40, labelSize.height + 20);
    [self.addressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
}

- (NSString *)stringByAppendingAddressStringWithSearchResponse:(AMapReGeocodeSearchResponse *)response
{
    NSMutableString *formattedAddress = [NSMutableString stringWithString:response.regeocode.formattedAddress];
    
    if (response.regeocode.addressComponent.streetNumber.street.length > 0  && response.regeocode.addressComponent.streetNumber.number.length > 0) {
        [formattedAddress appendString:[NSString stringWithFormat:@"（%@%@）", response.regeocode.addressComponent.streetNumber.street, response.regeocode.addressComponent.streetNumber.number]];
    }
    
    return [NSString stringWithString:formattedAddress];
}

@end
