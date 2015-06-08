//
//  DeviceInfo.m
//  HappyTrain
//
//  Created by jt on 14-10-23.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import "DeviceInfo.h"
#import "Constants.h"

#import <SFHFKeychainUtils.h>

#define kServiceName  [kKeyChainBaseServer append:@".device"]
#define kUserName   @"VendorID"

@implementation DeviceInfo
@synthesize deviceID = _deviceID;

- (instancetype)init
{
    self = [super init];
    
    _screenSize = [[UIScreen mainScreen] bounds].size;
    
    _screenScale = [[UIScreen mainScreen] scale];
    
    _osVersion = [[UIDevice currentDevice] systemVersion];
    
    return self;
}

- (NSString *)deviceID
{
    if (!_deviceID) {
        _deviceID = [SFHFKeychainUtils getPasswordForUsername:kUserName andServiceName:kServiceName error:nil];
        if (!_deviceID) {
            _deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            [SFHFKeychainUtils storeUsername:kUserName andPassword:_deviceID forServiceName:kServiceName updateExisting:YES error:nil];
        }
    }
    return _deviceID;
}
@end
