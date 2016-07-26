//
//  BankCardDetailVC.h
//  XiaoMa
//
//  Created by St.Jimmy on 4/1/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKBankCard.h"

@interface BankCardDetailVC : UIViewController

@property (nonatomic, strong) HKBankCard *card;
@property (nonatomic, weak) UIViewController *originVC;

@end
