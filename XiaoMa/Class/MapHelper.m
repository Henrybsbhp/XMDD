//
//  MapHelper.m
//  XiaoMa
//
//  Created by jt on 15-4-16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MapHelper.h"
#import "HKMapView.h"


@interface MapHelper()

@property (nonatomic, strong)AMapLocationManager *locationManager;

@end

@implementation MapHelper


+ (MapHelper *)sharedHelper
{
    static dispatch_once_t onceToken;
    static MapHelper *g_mapManager;
    dispatch_once(&onceToken, ^{
        g_mapManager = [[MapHelper alloc] init];
    });
    return g_mapManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
//        [self fetchAddressComponetDict];
    }
    return self;
}

- (void)setupMapApi
{
    [AMapServices sharedServices].apiKey = AMAP_API_ID;
    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [self.locationManager setLocationTimeout:1];
    [self.locationManager setReGeocodeTimeout:2];
}


- (RACSignal *)rac_getUserLocation
{
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [self.locationManager requestLocationWithReGeocode:NO completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
            
            if (error)
            {
                DebugLog(@"rac_getUserLocationAndInvertGeoInfo:%ld-%@", (long)error.code, error.localizedDescription);
                
                if (error.code == AMapLocationErrorLocateFailed || (!location))
                {
                    [subscriber sendError:error];
                }
            }
            
            if (location)
            {
                DebugLog(@"rac_getUserLocationAndInvertGeoInfo:location:%@", location);
                self.coordinate = location.coordinate;
            }
            
            [subscriber sendNext:location];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
    
    return signal;
}

- (RACSignal *)rac_getUserLocationAndInvertGeoInfo
{
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
            
            if (error)
            {
                DebugLog(@"rac_getUserLocationAndInvertGeoInfo:%ld-%@", (long)error.code, error.localizedDescription);
                
                if (error.code == AMapLocationErrorLocateFailed || (!location) || (!regeocode))
                {
                    [subscriber sendError:error];
                }
            }
            
            if (location && regeocode)
            {
                DebugLog(@"rac_getUserLocationAndInvertGeoInfo:location:%@", location);
                self.coordinate = location.coordinate;
                DebugLog(@"rac_getUserLocationAndInvertGeoInfo:regeocode:%@", regeocode);
                [self saveAddressComponent:regeocode];
                
                [subscriber sendNext:RACTuplePack(location,regeocode)];
                [subscriber sendCompleted];
            }
            
           
        }];
        
        return nil;
    }];
    
    return signal;
}


#pragma mark - Utility
- (void)saveAddressComponent:(AMapLocationReGeocode *)reGeocode
{
    HKAddressComponent *hkcomponent = [HKAddressComponent addressComponentWithReGeocode:reGeocode];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:hkcomponent];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"HKAddressComponent"];
    self.addrComponent = hkcomponent;
}

- (void)fetchAddressComponetDict
{
     NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"HKAddressComponent"];
    if (data) {
        self.addrComponent = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
}

- (void)handleGPSError:(NSError *)error
{
    switch (error.code) {
        case kCLErrorDenied:
        {
            if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
            {
                UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"您没有打开定位服务,请前往设置打开,然后刷新页面" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"前往设置", nil];
                
                [[av rac_buttonClickedSignal] subscribeNext:^(id x) {
                    
                    if ([x integerValue] == 1)
                    {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }
                }];
                [av show];
            }
            else
            {
                UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"您没有打开定位服务,请前往设置打开，然后刷新页面" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
                
                [av show];
            }
            break;
        }
        case LocationFail:
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"城市定位失败,请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            
            [av show];
        }
        default:
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"定位失败，请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            
            [av show];
            break;
        }
    }
}

@end

