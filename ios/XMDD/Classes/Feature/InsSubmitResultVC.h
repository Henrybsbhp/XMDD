//
//  InsSubmitResultVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/11.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InsuranceVM.h"

@interface InsSubmitResultVC : HKViewController
@property (nonatomic, strong) NSArray *couponList;
@property (nonatomic, strong) NSNumber *insOrderID;
@property (nonatomic, strong) InsuranceVM *insModel;
@end
