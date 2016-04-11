//
//  MutualInsPayResultVC.h
//  XiaoMa
//
//  Created by RockyYe on 16/3/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MutualInsContract.h"

@interface MutualInsPayResultVC : UIViewController

@property (nonatomic)BOOL isFromOrderInfoVC;

@property (nonatomic,strong)MutualInsContract * contract;

@end
