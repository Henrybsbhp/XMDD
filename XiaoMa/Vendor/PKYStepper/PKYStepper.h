//
//  PKYStepper.h
//  PKYStepper
//
//  Created by Okada Yohei on 1/11/15.
//  Copyright (c) 2015 yohei okada. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKYStepper;
// called when value is changed
typedef void (^PKYStepperValueChangedCallback)(PKYStepper *stepper, float newValue);

// called when value is incremented
typedef float (^PKYStepperIncrementCallback)(PKYStepper *stepper, float newValue);


// called when value is decremented
typedef float (^PKYStepperDecrementCallback)(PKYStepper *stepper, float newValue);

IB_DESIGNABLE
@interface PKYStepper : UIControl
@property(nonatomic, strong) UILabel *countLabel;
@property(nonatomic, strong) UIColor *labelColor;
@property(nonatomic, strong) UIButton *incrementButton;
@property(nonatomic, strong) UIButton *decrementButton;

@property(nonatomic) float value; // default: 0.0
@property(nonatomic) float stepInterval; // default: 1.0
@property(nonatomic) float minimum; // default: 0.0
@property(nonatomic) float maximum; // default: 100.0
@property(nonatomic) BOOL hidesDecrementWhenMinimum; // default: NO
@property(nonatomic) BOOL hidesIncrementWhenMaximum; // default: NO
@property(nonatomic) CGFloat buttonWidth; // default: 44.0f

@property(nonatomic, copy) PKYStepperValueChangedCallback valueChangedCallback;
@property(nonatomic, copy) PKYStepperIncrementCallback incrementCallback;
@property(nonatomic, copy) PKYStepperDecrementCallback decrementCallback;

///内置数值范围
@property (nonatomic, strong) NSArray *valueList;
///在数值范围内进行增减,默认为NO(忽略stepInterval参数)
@property (nonatomic, assign) BOOL allowValueList;
@property (nonatomic, assign) NSInteger curValueIndex;

// call this method after setting value(s) and callback(s)
// This method will call callback
- (void)setup;
+ (float)fitValueForValue:(float)value inValueList:(NSArray *)valueList;
// view customization
- (void)setBorderColor:(UIColor *)color;
- (void)setBorderWidth:(CGFloat)width;
- (void)setCornerRadius:(CGFloat)radius;

- (void)setLabelTextColor:(UIColor *)color;
- (void)setLabelFont:(UIFont *)font;

- (void)setButtonTextColor:(UIColor *)color forState:(UIControlState)state;
- (void)setButtonFont:(UIFont *)font;

@end
