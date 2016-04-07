//
//  GasCardListVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GasBaseVM.h"

@interface GasCardListVC : HKViewController
@property (nonatomic, strong) NSNumber *selectedGasCardID;
@property (nonatomic, copy) void(^selectedBlock)(GasCard *selectedCard);

@end
