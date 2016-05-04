//
//  CreateGroupVC.h
//  XiaoMa
//
//  Created by St.Jimmy on 3/16/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateGroupVC : HKViewController

@property (nonatomic, weak) UIViewController *originVC;
@property (nonatomic, strong) NSNumber *originGroupID;
@property (nonatomic, strong) NSNumber *originMemberID;

@end
