//
//  InsuranceChooseViewController.h
//  XiaoMa
//
//  Created by jt on 15/8/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureRecord.h"

@interface InsuranceChooseViewController : UIViewController

@property (nonatomic,copy)NSString * idcard;
@property (nonatomic, strong) PictureRecord *currentRecord;

@end
