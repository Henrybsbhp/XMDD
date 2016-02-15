//
//  InsInputNameVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/8.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKLimitTextField.h"

@interface InsInputNameVC : HKViewController

@property (weak, nonatomic) IBOutlet CKLimitTextField *nameField;
@property (weak, nonatomic) IBOutlet UIButton *ensureButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end
