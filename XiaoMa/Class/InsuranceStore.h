//
//  InsuranceStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/14.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "UserStore.h"
#import "InsSimpleCar.h"
#import "Area.h"
#import "JTQueue.h"

#define kEvtInsSimpleCars                           @"ins.simpleCars"
#define kEvtUpdateInsSimpleCar                      @"ins.simpleCar.update"
#define kEvtInsProvinces                            @"ins.provinces"
#define kEvtInsSimpleCarsAndProvinces               @"ins.simpleCarsAndProvinces"

@interface InsuranceStore : UserStore
@property (nonatomic, strong) JTQueue *simpleCars;
@property (nonatomic, strong) JTQueue *insProvinces; ///保险支持的省份
@property (nonatomic, strong) NSString *xmddHelpTip; ///马达帮助文案

//Fetch
- (CKEvent *)reloadInsSimpleCarsAndProvinces;
- (CKEvent *)getInsSimpleCars;
- (CKEvent *)getInsProvinces;

//Update
- (CKEvent *)updateSimpleCarRefid:(NSNumber *)refid byLicenseno:(NSString *)licenseno;

@end
