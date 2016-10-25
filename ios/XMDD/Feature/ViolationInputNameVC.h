//
//  ViolationInputNameVC.h
//  XMDD
//
//  Created by RockyYe on 2016/10/21.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViolationInputNameVC : UIViewController
@property (weak, nonatomic) IBOutlet CKLimitTextField *nameField;
@property (weak, nonatomic) IBOutlet UIButton *ensureButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end
