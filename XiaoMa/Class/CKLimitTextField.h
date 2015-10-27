//
//  CKLimitTextField.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CKLimitTextFieldDelegate;

@interface CKLimitTextField : UITextField
@property (nonatomic, assign) NSInteger textLimit;
@property (nonatomic, copy) void (^textChangedBlock)(CKLimitTextField *textField);

@end
