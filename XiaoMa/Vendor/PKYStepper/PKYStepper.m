//
//  PKYStepper.m
//  PKYStepper
//
//  Created by Okada Yohei on 1/11/15.
//  Copyright (c) 2015 yohei okada. All rights reserved.
//

// action control: UIControlEventApplicationReserved for increment/decrement?
// delegate: if there are multiple PKYSteppers in one viewcontroller, it will be a hassle to identify each PKYSteppers
// block: watch out for retain cycle

// check visibility of buttons when
// 1. right before displaying for the first time
// 2. value changed

#import "PKYStepper.h"

static const float kButtonWidth = 44.0f;

@implementation PKYStepper

#pragma mark initialization
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _value = 0.0f;
    _stepInterval = 1.0f;
    _minimum = 0.0f;
    _maximum = 100.0f;
    _curValueIndex = NSNotFound;
    _hidesDecrementWhenMinimum = NO;
    _hidesIncrementWhenMaximum = NO;
    _buttonWidth = kButtonWidth;
    
    self.clipsToBounds = YES;
    [self setBorderWidth:1.0f];
    [self setCornerRadius:3.0];
    
    self.countLabel = [[UILabel alloc] init];
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    self.countLabel.layer.borderWidth = 1.0f;
    [self addSubview:self.countLabel];
    
    self.incrementButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.incrementButton setTitle:@"+" forState:UIControlStateNormal];
    [self.incrementButton addTarget:self action:@selector(incrementButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.incrementButton];
    
    self.decrementButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.decrementButton setTitle:@"-" forState:UIControlStateNormal];
    [self.decrementButton addTarget:self action:@selector(decrementButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.decrementButton];
    
    UIColor *defaultColor = [UIColor colorWithRed:(79/255.0) green:(161/255.0) blue:(210/255.0) alpha:1.0];
    [self setBorderColor:defaultColor];
    [self setLabelTextColor:defaultColor];
    [self setButtonTextColor:defaultColor forState:UIControlStateNormal];
    
    [self setLabelFont:[UIFont fontWithName:@"Avernir-Roman" size:14.0f]];
    [self setButtonFont:[UIFont fontWithName:@"Avenir-Black" size:24.0f]];
}


#pragma mark render
- (void)layoutSubviews
{
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    self.countLabel.frame = CGRectMake(self.buttonWidth, 0, width - (self.buttonWidth * 2), height);
    self.incrementButton.frame = CGRectMake(width - self.buttonWidth, 0, self.buttonWidth, height);
    self.decrementButton.frame = CGRectMake(0, 0, self.buttonWidth, height);
    
    self.incrementButton.hidden = (self.hidesIncrementWhenMaximum && [self isMaximum]);
    self.decrementButton.hidden = (self.hidesDecrementWhenMinimum && [self isMinimum]);
}

- (void)setup
{
    if (self.valueChangedCallback)
    {
        self.valueChangedCallback(self, _value);
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    if (CGSizeEqualToSize(size, CGSizeZero))
    {
        // if CGSizeZero, return ideal size
        CGSize labelSize = [self.countLabel sizeThatFits:size];
        return CGSizeMake(labelSize.width + (self.buttonWidth * 2), labelSize.height);
    }
    return size;
}


#pragma mark view customization
- (void)setBorderColor:(UIColor *)color
{
    self.layer.borderColor = color.CGColor;
    self.countLabel.layer.borderColor = color.CGColor;
}

- (void)setBorderWidth:(CGFloat)width
{
    self.layer.borderWidth = width;
    self.countLabel.layer.borderWidth = width;
}

- (void)setCornerRadius:(CGFloat)radius
{
    self.layer.cornerRadius = radius;
}

- (void)setLabelTextColor:(UIColor *)color
{
    self.countLabel.textColor = color;
}

- (void)setLabelFont:(UIFont *)font
{
    self.countLabel.font = font;
}

- (void)setButtonTextColor:(UIColor *)color forState:(UIControlState)state
{
    [self.incrementButton setTitleColor:color forState:state];
    [self.decrementButton setTitleColor:color forState:state];
}

- (void)setButtonFont:(UIFont *)font
{
    self.incrementButton.titleLabel.font = font;
    self.decrementButton.titleLabel.font = font;
}


#pragma mark setter
- (void)setValue:(float)value
{
    if (self.allowValueList && self.valueList.count > 0) {
        _value = [PKYStepper fitValueForValue:value inValueList:self.valueList];
    }
    else {
        _value = MAX(MIN(value, self.maximum), self.minimum);
        if (self.hidesDecrementWhenMinimum)
        {
            self.decrementButton.hidden = [self isMinimum];
        }
        
        if (self.hidesIncrementWhenMaximum)
        {
            self.incrementButton.hidden = [self isMaximum];
        }
    }
}

- (void)setAllowValueList:(BOOL)allowValueList
{
    _allowValueList = allowValueList;
    if (allowValueList && self.valueList.count > 0) {

        float fitValue = [self.valueList[0] floatValue];
        NSInteger index = 0;
        
        for (NSInteger i = 1; i < self.valueList.count; i++) {
            float curValue = [self.valueList[i] floatValue];
            if (fabs(curValue - self.value) < fabs(fitValue - self.value)) {
                fitValue = curValue;
                index = i;
            }
        }
        self.curValueIndex = index;
        self.value = fitValue;
    }
}

+ (float)fitValueForValue:(float)value inValueList:(NSArray *)valueList
{
    float fitValue = [valueList[0] floatValue];
    
    for (NSInteger i = 1; i < valueList.count; i++) {
        float curValue = [valueList[i] floatValue];
        if (fabs(curValue - value) < fabs(fitValue - value)) {
            fitValue = curValue;
        }
    }
    return fitValue;
}

+ (float)incrementValue:(float)value inValueList:(NSArray *)valueList
{
    float newValue = value;
    NSInteger count = valueList.count;
    for (NSInteger i = 0; i < count; i++) {
        newValue = [valueList[i] floatValue];
        if (value < newValue) {
            break;
        }
        else if ([self isEqualForValue1:value andValue2:newValue]) {
            newValue = [valueList[MIN(count-1, i+1)] floatValue];
            break;
        }
    }
    return newValue;
}

+ (float)decrementValue:(float)value inValueList:(NSArray *)valueList
{
    float newValue = value;
    NSInteger count = valueList.count;
    for (NSInteger i = count-1; i >= 0; i--) {
        newValue = [valueList[i] floatValue];
        if (value > newValue) {
            break;
        }
        else if ([self isEqualForValue1:value andValue2:newValue]) {
            newValue = [valueList[MAX(0, i-1)] floatValue];
            break;
        }
    }
    return newValue;
}

+ (BOOL)isEqualForValue1:(float)value1 andValue2:(float)value2
{
    if (fabs(value1 - value2) < 0.01) {
        return YES;
    }
    return NO;
}
#pragma mark event handler
- (void)incrementButtonTapped:(id)sender
{
    return;
    float newValue = self.value;
    if (self.allowValueList && self.valueList.count > 0) {
        if (self.curValueIndex+1 < self.valueList.count) {
            self.curValueIndex = self.curValueIndex + 1;
            newValue = [self.valueList[self.curValueIndex] floatValue];
        }
    }
    else {
        newValue = self.value + self.stepInterval;
    }
    if (self.incrementCallback) {
        newValue = self.incrementCallback(self, newValue);
    }
    self.value = newValue;
    [self setup];
}

- (void)decrementButtonTapped:(id)sender
{
    return;
    float newValue = self.value;
    if (self.allowValueList && self.valueList.count > 0) {
        if (self.curValueIndex-1 >= 0) {
            self.curValueIndex = self.curValueIndex - 1;
            newValue = [self.valueList[self.curValueIndex] floatValue];
        }
    }
    else {
        newValue = self.value - self.stepInterval;
    }
    
    if (self.decrementCallback) {
        newValue = self.decrementCallback(self, newValue);
    }
    self.value = newValue;
    [self setup];
}


#pragma mark private helpers
- (BOOL)isMinimum
{
    return self.value == self.minimum;
}

- (BOOL)isMaximum
{
    return self.value == self.maximum;
}

@end
