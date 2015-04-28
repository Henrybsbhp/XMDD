//
//  CarWashNavigationViewController.m
//  XiaoMa
//
//  Created by jt on 15-4-16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CarWashNavigationViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>



@interface CarWashNavigationViewController ()<UIActionSheetDelegate>

@property (nonatomic)CLLocationCoordinate2D startCoordinate;
@property (nonatomic)CLLocationCoordinate2D endCoordinate;

@property (nonatomic)BOOL exsitBaiduMap;
@property (nonatomic)BOOL exsitAMap;
@property (nonatomic)NSInteger cancelIndex;

@end

@implementation CarWashNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.shop.shopName;
    
    self.endCoordinate = CLLocationCoordinate2DMake(self.shop.shopLatitude, self.shop.shopLongitude);
    self.cancelIndex = 1;
    
    CKAsyncMainQueue(^{
        self.mapView.showsUserLocation = YES;
        self.mapView.userTrackingMode = MAUserTrackingModeFollow;
        [self setCenter];
        [self addDefaultAnnotations];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - U
- (void)addDefaultAnnotations
{
    MAPointAnnotation *destinationAnnotation = [[MAPointAnnotation alloc] init];
    destinationAnnotation.coordinate = CLLocationCoordinate2DMake(self.shop.shopLatitude, self.shop.shopLongitude);
    destinationAnnotation.title      = self.shop.shopName;
    destinationAnnotation.subtitle   = self.shop.shopAddress;
    
    [self.mapView addAnnotation:destinationAnnotation];
    
//    [self.mapView setCenterCoordinate:destinationAnnotation.coordinate animated:YES];
//    [self.mapView setZoomLevel:ZoomLevel animated:YES];
}

- (void)setCenter
{
    [self.mapView setZoomLevel:MapZoomLevel animated:YES];
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(self.shop.shopLatitude, self.shop.shopLongitude) animated:YES];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)theSingleTap
{
    self.exsitBaiduMap = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://map/"]];
    self.exsitAMap = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]];
    UIActionSheet * sheet;
    if (self.exsitBaiduMap)
    {
        if (self.exsitAMap)
        {
            sheet = [[UIActionSheet alloc] initWithTitle:@"请选择导航软件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:AppleNavigationStr,BaiduNavigationStr,AMapNavigationStr,nil];
            self.cancelIndex = 3;
        }
        else
        {
           sheet = [[UIActionSheet alloc] initWithTitle:@"请选择导航软件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:AppleNavigationStr,BaiduNavigationStr,nil];
            self.cancelIndex = 2;
        }
    }
    else
    {
        if (self.exsitAMap)
        {
            sheet = [[UIActionSheet alloc] initWithTitle:@"请选择导航软件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:AppleNavigationStr,AMapNavigationStr,nil];
            self.cancelIndex = 2;
        }
        else
        {
            sheet = [[UIActionSheet alloc] initWithTitle:@"请选择导航软件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:AppleNavigationStr,nil];
            self.cancelIndex = 1;
        }
    }
    
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == self.cancelIndex)
    {
        return;
    }
    NSString * baiduUrlString = [[NSString stringWithFormat:@"baidumap://map/direction?mode=driving&origin=latlng:%f,%f|name:我的位置&destination=latlng:%f,%f|name:%@&zoom=10&src=小马达达",self.startCoordinate.latitude,self.startCoordinate.longitude,self.shop.shopLatitude,self.shop.shopLongitude,self.shop.shopName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *amapUrlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=1&style=2&poiname=%@",@"小马达达", @"com.huika.xmdd",self.shop.shopLatitude, self.shop.shopLongitude,self.shop.shopName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (buttonIndex == 0)
    {
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:self.endCoordinate addressDictionary:nil]];
        toLocation.name = self.shop.shopName;
        
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
    }
    else if (buttonIndex == 1)
    {
        if (self.exsitBaiduMap)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:baiduUrlString]];
        }
        else
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:amapUrlString]];

        }
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:amapUrlString]];
    }
    
}


#pragma mark - MAMapViewDelegate
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *navigationCellIdentifier = @"navigationCellIdentifier";
        
        MAAnnotationView *poiAnnotationView = (MAAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:navigationCellIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:navigationCellIdentifier];
        }
        
        UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [poiAnnotationView addGestureRecognizer:singleTap];
        
        poiAnnotationView.canShowCallout = YES;
        
        poiAnnotationView.image = [UIImage imageNamed:@"cw_alipay"];
        
        return poiAnnotationView;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation;
{
    self.startCoordinate = userLocation.location.coordinate;
}
@end
