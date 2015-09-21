//
//  InsuranceInfoSubmitingVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger
{
    InsuranceInfoSubmitForDirectSell = 0,
    InsuranceInfoSubmitForEnquiry = 1
}InsuranceInfoSubmitModel;

@interface InsuranceInfoSubmitingVC : UIViewController
@property (nonatomic, assign) InsuranceInfoSubmitModel submitModel;
@property (nonatomic, strong) NSString *calculatorID;

@end
