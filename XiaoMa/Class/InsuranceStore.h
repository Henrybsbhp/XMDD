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

@interface InsuranceStore : UserStore
@property (nonatomic, strong) JTQueue *simpleCars;
@property (nonatomic, strong) JTQueue *insProvinces; ///保险支持的省份
@property (nonatomic, strong) NSString *xmddHelpTip; ///马达帮助文案

//Fetch
///获取保险车辆简单信息（内部会调用"getInsProvinces:NO"）
- (CKEvent *)getInsSimpleCars;
///获取保险支持的省份信息
- (CKEvent *)getInsProvinces:(BOOL)force;
///更新保险车辆基本信息
- (CKEvent *)updateSimpleCar:(InsSimpleCar *)car;

@end
