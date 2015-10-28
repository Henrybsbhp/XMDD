//
//  CKLimitTextField.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CKLimitTextFieldProxyObject;

@interface CKLimitTextField : UITextField
@property (nonatomic, strong) UITextPosition *curCursorPosition;
@property (nonatomic, assign) NSInteger textLimit;
@property (nonatomic, strong) NSString *regexpPattern;
@property (nonatomic, copy) void (^didBeginEditingBlock)(CKLimitTextField *textField);
@property (nonatomic, copy) void (^didEndEditingBlock)(CKLimitTextField *textField);
@property (nonatomic, copy) void (^textChangingBlock)(CKLimitTextField *textField);
@property (nonatomic, copy) void (^textDidChangedBlock)(CKLimitTextField *textField);
@property (nonatomic, copy) BOOL (^shouldChangeBlock)(CKLimitTextField *field, NSRange range, NSString *replaceStr);
@end

@interface CKLimitTextFieldProxyObject : NSObject<UITextFieldDelegate>
@property (nonatomic, weak) CKLimitTextField *textField;

- (void)actionTextDidChanged:(CKLimitTextField *)textField;
@end