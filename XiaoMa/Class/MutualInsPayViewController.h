//
//  MutualInsPayViewController.h
//  XiaoMa
//
//  Created by jt on 16/3/8.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKViewController.h"
#import "MutualInsContract.h"

@interface MutualInsPayViewController : HKViewController

@property (nonatomic,strong)MutualInsContract * contract;
///是否代买交强险
@property (nonatomic)BOOL proxybuy;

@end
