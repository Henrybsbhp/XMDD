//
//  MutualInsGroupInfoVC.h
//  XiaoMa
//
//  Created by St.Jimmy on 3/18/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MutualInsGroupInfoVC : UIViewController

@property (nonatomic, weak) UIViewController *originVC;

@property (nonatomic,strong)NSNumber * groupId;

@property (nonatomic,strong)NSString * groupName;

@property (nonatomic,strong)NSString * groupCreateName;

@property (nonatomic,strong)NSString * cipher;

@end
