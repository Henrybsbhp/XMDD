//
//  ViolationMyLicenceVC.h
//  XMDD
//
//  Created by RockyYe on 16/8/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViolationMyLicenceVC : UIViewController

@property (strong, nonatomic) NSNumber *usercarID;

@property (strong, nonatomic) NSString *carNum;

@property (strong, nonatomic)void(^commitSuccessBlock)(void);

@end
