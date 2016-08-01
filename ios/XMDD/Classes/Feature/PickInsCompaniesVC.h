//
//  PickerInsCompnaiesVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/26.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickInsCompaniesVC : HKViewController
@property (nonatomic, copy) void(^pickedBlock)(NSString *pickedName);
@end
