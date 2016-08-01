//
//  SJKeyboardManager.h
//  XiaoMa
//
//  Created by St.Jimmy on 4/13/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SJKeyboardManager : NSObject

+ (instancetype)sharedManager;

- (void)moveUpWithViewController:(UIViewController *)viewController view:(UIView *)view textField:(UITextField *)textField bottomLayoutConstraint:(NSLayoutConstraint *)bottomConstraint bottomView:(UIView *)bottomView;

- (void)moveUpWithViewController:(UIViewController *)viewController tableView:(UITableView *)tableView textField:(UITextField *)textField bottomView:(UIView *)bottomView atIndexPath:(NSIndexPath *)indexPath;

@end
