//
//  InsuranceVM.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/16.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKInsuranceOrder.h"
#import "InsSimpleCar.h"

@interface InsuranceVM : NSObject<NSCopying>
@property (nonatomic, strong) InsSimpleCar *simpleCar;
///用户姓名
@property (nonatomic, strong) NSString *realName;
/// 座位数
@property (nonatomic,strong) NSNumber * numOfSeat;
///保险公司代号
@property (nonatomic, strong) NSString *inscomp;
///保险公司名字
@property (nonatomic, strong) NSString *inscompname;

@property (nonatomic, weak) UIViewController *originVC;

- (NSArray *)createCoveragesList;

@end
