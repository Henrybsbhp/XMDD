//
//  InsInputInfoVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/8.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InsSimpleCar;

@interface InsInputInfoVC : UIViewController

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *licenseNumber;
///保险车辆关联记录id
@property (nonatomic, strong) NSNumber *refid;

@end
