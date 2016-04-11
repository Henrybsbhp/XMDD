//
//  MutualInsPayViewController.h
//  XiaoMa
//
//  Created by jt on 16/3/8.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKViewController.h"
#import "MutualInsContract.h"
#import "HKMutualGroup.h"
@interface MutualInsPayViewController : HKViewController

@property (nonatomic,strong)MutualInsContract * contract;


@property (nonatomic, strong) HKMutualGroup *group;
///是否代买交强险
@property (nonatomic)BOOL proxybuy;

- (void)tableViewReloadData;

@end
