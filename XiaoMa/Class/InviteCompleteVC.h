//
//  InviteCompleteVC.h
//  XiaoMa
//
//  Created by jt on 16/3/21.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKAlertVC.h"

@interface InviteCompleteVC : HKAlertVC

@property (nonatomic,strong)NSArray<NSDictionary *> * datasource;

@property (nonatomic,strong)NSArray<NSString *> * datasource2;

@property (nonatomic,copy)void(^closeAction)(void);

@end
