//
//  CKLimitTextField.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CKLimitTextField.h"

@interface CKLimitTextField ()
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate
{
    
}

- (void)_textFieldDidChanged:(NSNotification *)notify
{
    CKLimitTextField *textField = notify.object;
    if (self.textChangedBlock) {
        self.textChangedBlock(textField);
    }
    if (self.textLimit == 0) {
        return;
    }
    if (self.textLimit < textField.text.length) {
        textField.text = [textField.text substringToIndex:self.textLimit];
        [textField sendActionsForControlEvents:UIControlEventEditingChanged];
    }
}

@end
