//
//  InsCheckFailVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/21.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InsuranceVM.h"

@interface InsCheckFailVC : UIViewController

@property (nonatomic, strong) InsuranceVM *insModel;
@property (nonatomic, strong) NSString *errmsg;

@end
