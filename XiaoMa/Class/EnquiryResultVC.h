//
//  EnquiryResultVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/12.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKMyCar.h"

@interface EnquiryResultVC : UITableViewController
@property (nonatomic, strong, readonly) NSArray *insurances;
@property (nonatomic, strong, readonly) NSString *calculatorID;
@property (nonatomic, strong) HKMyCar *car;
@property (nonatomic, assign) BOOL shouldUpdateCar;

- (void)reloadWithInsurance:(NSArray *)insurances calculatorID:(NSString *)cid;

@end
