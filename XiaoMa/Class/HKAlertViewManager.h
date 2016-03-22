//
//  HKAlertViewManager.h
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/22.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKDatasource.h"

@interface HKAlertViewManager : NSObject

- (CKDict *)getAlertDic;

- (void)showAlert;

- (void)dismissAlert;

@end
