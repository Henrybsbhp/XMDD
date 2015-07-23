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
    
    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
    _appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
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

///检测关键字是否第一次在当前版本出现过
- (BOOL)firstAppearAtThisVersionForKey:(NSString *)key
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *name = @"$CheckKeyForThisVersion";
    NSDictionary *dict = [def persistentDomainForName:name];
    NSString *version = dict[@"$app_version"];
    //当前版本大于上次检测到的版本
    if ([self.appVersion compare:version options:NSCaseInsensitiveSearch] == NSOrderedDescending) {
        [self _saveKey:key forDomain:dict withName:name];
        return YES;
    }
    //如果还不存在这个key
    if (![dict objectForKey:key]) {
        [self _saveKey:key forDomain:dict withName:name];
        return YES;
    }
    return NO;
}

#pragma mark - Private
- (void)_saveKey:(NSString *)key forDomain:(NSDictionary *)domain withName:(NSString *)name
{
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:domain];
    [newDict safetySetObject:@YES forKey:key];
    [newDict safetySetObject:self.appVersion forKey:@"$app_version"];
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:newDict forName:name];
}

@end
