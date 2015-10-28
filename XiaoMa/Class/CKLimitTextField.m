//
//  CKLimitTextField.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CKLimitTextField.h"

@interface CKLimitTextField ()<UITextFieldDelegate>
@property (nonatomic, strong) NSString *oldText;
@property (nonatomic, strong, readonly) UITextPosition *oldCursorPosition;
@end

@implementation CKLimitTextField

- (id)initWithFrame:(CGRect) frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *) inCoder {
    self = [super initWithCoder:inCoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.delegate = self;
    [self addTarget:self action:@selector(actionTextDidChanged:) forControlEvents:UIControlEventEditingChanged];
    NSLog(@"self.inputdelegate = %@", self.inputDelegate);
}

- (void)actionTextDidChanged:(CKLimitTextField *)textField
{
    self.curCursorPosition = textField.selectedTextRange.start;
    UITextRange *markedRange = textField.markedTextRange;
    BOOL isAtEnd = [textField comparePosition:self.curCursorPosition toPosition:textField.endOfDocument] == NSOrderedSame;
    
    if (!markedRange) {
        if (self.regexpPattern) {
            NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:self.regexpPattern options:0 error:nil];
            NSTextCheckingResult *rst = [regexp firstMatchInString:textField.text options:0 range:NSMakeRange(0, textField.text.length)];
            if (rst.range.location == NSNotFound) {
                textField.text = self.oldText;
                self.curCursorPosition = self.oldCursorPosition;
            }
            else {
                textField.text = [textField.text substringWithRange:rst.range];
                self.curCursorPosition = textField.endOfDocument;
            }
        }
        if (self.textChangingBlock) {
            self.textChangingBlock(textField);
        }
    }
    if (self.textLimit > 0 && self.textLimit < textField.text.length) {
        textField.text = [textField.text substringToIndex:self.textLimit];
        NSInteger diffOffset = [textField offsetFromPosition:self.curCursorPosition toPosition:textField.endOfDocument];
        if (!isAtEnd && diffOffset > 0) {
            textField.selectedTextRange = [textField textRangeFromPosition:self.curCursorPosition toPosition:self.curCursorPosition];
        }
        [textField sendActionsForControlEvents:UIControlEventEditingChanged];
    }
    else {
        NSInteger diffOffset = [textField offsetFromPosition:self.curCursorPosition toPosition:textField.endOfDocument];
        if (!isAtEnd && diffOffset > 0) {
            textField.selectedTextRange = [textField textRangeFromPosition:self.curCursorPosition toPosition:self.curCursorPosition];
        }
        if (self.textDidChangedBlock) {
            self.textDidChangedBlock(textField);
        }
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.didBeginEditingBlock) {
        self.didBeginEditingBlock(self);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _oldCursorPosition = nil;
    if (self.didEndEditingBlock) {
        self.didEndEditingBlock(self);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UITextPosition *cursorPos = textField.selectedTextRange.start;
    UITextRange *markedRange = textField.markedTextRange;
    _oldCursorPosition = markedRange ? markedRange.start : cursorPos;
    _oldText = textField.text;
    
    return YES;
}

@end
