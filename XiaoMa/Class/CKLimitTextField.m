//
//  CKLimitTextField.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CKLimitTextField.h"

@interface CKLimitTextField ()

@property (nonatomic, strong) CKLimitTextFieldProxyObject *proxyObject;

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
    _proxyObject = [[CKLimitTextFieldProxyObject alloc] init];
    _proxyObject.textField = self;
    self.delegate = _proxyObject;
    [self addTarget:_proxyObject action:@selector(actionTextDidChanged:) forControlEvents:UIControlEventEditingChanged];
}

- (void)setText:(NSString *)text {
    BOOL isAtEnd = YES;
    UITextPosition *pos = self.curCursorPosition;
    if (self.isEditing && self.curCursorPosition) {
        isAtEnd = [self comparePosition:self.curCursorPosition toPosition:self.endOfDocument] == NSOrderedSame;
    }
    [super setText:text];
    
    if (!isAtEnd && [self offsetFromPosition:pos toPosition:self.endOfDocument] > 0) {
        self.selectedTextRange = [self textRangeFromPosition:pos toPosition:pos];
    }
}

@end

@interface CKLimitTextFieldProxyObject ()
@property (nonatomic, strong) NSString *oldText;
@property (nonatomic, strong, readonly) UITextPosition *oldCursorPosition;
@property (nonatomic, strong) NSString *oldReplacement;
@end
@implementation CKLimitTextFieldProxyObject

- (void)actionTextDidChanged:(CKLimitTextField *)textField
{
    _textField.curCursorPosition = textField.selectedTextRange.start;
    UITextRange *markedRange = textField.markedTextRange;
    BOOL isAtEnd = [textField comparePosition:_textField.curCursorPosition toPosition:textField.endOfDocument] == NSOrderedSame;
    
    if (!markedRange) {
        if (_textField.regexpPattern) {
            NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:_textField.regexpPattern
                                                                                    options:0 error:nil];
            NSTextCheckingResult *rst = [regexp firstMatchInString:textField.text options:0 range:NSMakeRange(0, textField.text.length)];
            if (rst.range.location == NSNotFound) {
                textField.text = self.oldText;
                _textField.curCursorPosition = self.oldCursorPosition;
            }
            else {
                textField.text = [textField.text substringWithRange:rst.range];
                _textField.curCursorPosition = textField.endOfDocument;
            }
        }
        if (_textField.textChangingBlock) {
            _textField.textChangingBlock(textField, self.oldReplacement);
        }
    }
    if (_textField.textLimit > 0 && _textField.textLimit < textField.text.length) {
        textField.text = [textField.text substringToIndex:_textField.textLimit];
        NSInteger diffOffset = [textField offsetFromPosition:_textField.curCursorPosition toPosition:textField.endOfDocument];
        if (!isAtEnd && diffOffset > 0) {
            textField.selectedTextRange = [textField textRangeFromPosition:_textField.curCursorPosition toPosition:_textField.curCursorPosition];
        }
        
        [self performSelector:@selector(_callEditingChangedActions:) withObject:textField];
    }
    else {
        NSInteger diffOffset = [textField offsetFromPosition:_textField.curCursorPosition toPosition:textField.endOfDocument];
        if (!isAtEnd && diffOffset > 0) {
            textField.selectedTextRange = [textField textRangeFromPosition:_textField.curCursorPosition toPosition:_textField.curCursorPosition];
        }
        if (_textField.textDidChangedBlock) {
            _textField.textDidChangedBlock(textField);
        }
    }
}

- (void)_callEditingChangedActions:(CKLimitTextField *)textfield
{
    [textfield sendActionsForControlEvents:UIControlEventEditingChanged];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (_textField.didBeginEditingBlock) {
        _textField.didBeginEditingBlock(_textField);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _oldCursorPosition = nil;
    if (_textField.didEndEditingBlock) {
        _textField.didEndEditingBlock(_textField);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UITextPosition *cursorPos = textField.selectedTextRange.start;
    UITextRange *markedRange = textField.markedTextRange;
    _oldCursorPosition = markedRange ? markedRange.start : cursorPos;
    _oldText = textField.text;
    _oldReplacement = string;
    return YES;
}

@end
