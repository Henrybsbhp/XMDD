//
//  GasVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GasNormalVM.h"
#import "GasCZBVM.h"

@interface GasVC : UIViewController

@property (nonatomic, strong) GasNormalVM *normalModel;
@property (nonatomic, strong) GasCZBVM *czbModel;
@property (nonatomic, assign) GasBaseVM *curModel;

@end
