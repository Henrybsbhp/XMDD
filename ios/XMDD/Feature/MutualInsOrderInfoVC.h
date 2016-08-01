//
//  MutualInsOrderInfoVC.h
//  XiaoMa
//
//  Created by jt on 16/3/16.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKMutualGroup.h"

@interface MutualInsOrderInfoVC : HKViewController

@property (nonatomic,strong)NSNumber * contractId;

@property (nonatomic, strong) HKMutualGroup *group;

- (void)requestContractDetail;

@end

