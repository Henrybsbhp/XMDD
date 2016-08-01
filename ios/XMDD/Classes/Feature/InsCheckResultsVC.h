//
//  InsCheckResultsVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/9.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InsuranceVM;

@interface InsCheckResultsVC : HKViewController

@property (nonatomic, strong) InsuranceVM *insModel;
@property (nonatomic, strong) NSArray *premiumList;

@property (nonatomic, strong) NSString *headerTip;

@end
