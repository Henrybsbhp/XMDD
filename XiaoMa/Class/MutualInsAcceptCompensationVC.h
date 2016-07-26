//
//  MutualInsAcceptCompensationVC.h
//  XiaoMa
//
//  Created by St.Jimmy on 6/2/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MutualInsAcceptCompensationVC : UIViewController

/// 下发得到的 claimID
@property (nonatomic, strong) NSNumber *claimID;

/// 下发得到的底部描述信息文本
@property (nonatomic, copy) NSString *descriptionString;

/// 下发得到的用户姓名
@property (nonatomic, copy) NSString *usernameString;

/// 下发得到的银行卡号
@property (nonatomic, copy) NSString *fetchedBankCardNumber;

@end
