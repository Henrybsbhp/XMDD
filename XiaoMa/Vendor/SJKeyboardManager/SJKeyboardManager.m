//
//  SJKeyboardManager.m
//  XiaoMa
//
//  Created by St.Jimmy on 4/13/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "SJKeyboardManager.h"
#import <objc/runtime.h>

@interface SJKeyboardManager()

@property (nonatomic, copy) NSDictionary *originInfoDict;

@property (nonatomic, strong) UIViewController *targetViewController;
@property (nonatomic, strong) UIView *origrinView;
@property (nonatomic, strong) NSLayoutConstraint *originBottomLayout;
@property (nonatomic, strong) UITextField *originTextField;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) NSLayoutConstraint *bottomLayoutConstraint;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, retain) NSIndexPath *indexPath;

@property (nonatomic, assign) CGFloat upOffsetY;
@property (nonatomic, assign) CGRect originRect;
@property (nonatomic, assign) CGRect originBottomRect;

@end

@implementation SJKeyboardManager

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSDictionary *)originInfoArray
{
    if (!_originInfoDict) {
        _originInfoDict = [[NSDictionary alloc] init];
    }
    
    return _originInfoDict;
}

- (void)moveUpWithViewController:(UIViewController *)viewController view:(UIView *)view textField:(UITextField *)textField bottomLayoutConstraint:(NSLayoutConstraint *)bottomConstraint bottomView:(UIView *)bottomView
{
    _targetViewController = viewController;
    _originTextField = textField;
    _bottomLayoutConstraint = bottomConstraint;
    _origrinView = view;
    _bottomView = bottomView;
    _originRect = view.frame;
    _originBottomLayout = bottomConstraint;
    
    if (_originInfoDict == nil) {
        _originInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:bottomConstraint.constant], @"bottomLayout", nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)moveUpWithViewController:(UIViewController *)viewController tableView:(UITableView *)tableView textField:(UITextField *)textField bottomView:(UIView *)bottomView atIndexPath:(NSIndexPath *)indexPath
{
    _targetViewController = viewController;
    _originTextField = textField;
    _bottomLayoutConstraint = nil;
    _tableView = tableView;
    _bottomView = bottomView;
    _originRect = tableView.frame;
    _originBottomRect = bottomView.frame;
    _indexPath = indexPath;
    _originBottomLayout = nil;
    
    if (_originInfoDict == nil) {
        _originInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGRect:bottomView.frame], @"bottomFrame", nil];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}


+ (instancetype)sharedManager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       manager = [[self alloc] init];
    });
    
    return manager;
}

//将输入框架弹起
- (void)keyboardWillShow:(NSNotification *)notification
{
    //如果是手动布局就计算输入框架的frame,如果是自动布局,那就添加或修改约束
    //键盘有多高
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    //键盘升起动画的时长
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    //动画选项
    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey]intValue];
    
    if (self.bottomLayoutConstraint == nil) {
   
        self.origrinView.frame = self.originRect;
    
        CGRect originTableRect = self.tableView.frame;
    
        originTableRect.origin.y = 0;
    
        self.tableView.frame = originTableRect;
        self.bottomView.frame = self.originBottomRect;
        
        CGRect textFieldRectInTableView = [self.tableView rectForRowAtIndexPath:self.indexPath];
        CGRect originViewFrame = self.tableView.frame;
        CGRect bottomViewRect = self.bottomView.frame;
        bottomViewRect.origin.y = textFieldRectInTableView.origin.y + textFieldRectInTableView.size.height;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat remainingHeight = screenHeight - textFieldRectInTableView.origin.y - textFieldRectInTableView.size.height - 64 - keyboardFrame.size.height;
        
        if (remainingHeight < self.bottomView.bounds.size.height) {
            self.upOffsetY = self.bottomView.bounds.size.height - remainingHeight;
            originViewFrame.origin.y -= self.upOffsetY;
        }
        
        [UIView animateWithDuration:duration delay:0 options:options animations:^{
            self.bottomView.frame = bottomViewRect;
            self.tableView.frame = originViewFrame;
        } completion:nil];
        
        return;
        
    }
    
    CGRect rect = self.originRect;
    
    CGRect textFieldRect = [self.originTextField.superview convertRect:self.originTextField.frame toView:self.origrinView];
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat remainingHeight = screenHeight - textFieldRect.origin.y - textFieldRect.size.height - 64 - keyboardFrame.size.height;
    if (remainingHeight < self.bottomView.bounds.size.height) {
        self.upOffsetY = self.bottomView.bounds.size.height - remainingHeight;
        rect.origin.y = rect.origin.y - self.upOffsetY;
    }
    
//    rect.origin.y += 64;
    
    //让输入框架和键盘做完全一样的动画效果
    [UIView animateWithDuration:duration
                          delay:0
                        options:options
                     animations:^{
                         
                         //修改约束,让输入框架距离父视图的下边正好和键盘一样高
                         self.bottomLayoutConstraint.constant = keyboardFrame.size.height - self.upOffsetY;
                         
                         //让修改后的约束起作用
                         self.origrinView.frame = rect;
                         
                         [self.origrinView layoutIfNeeded];
                         
                     } completion:nil];
    
}

//让输入框回到下边
- (void)keyboardWillHide:(NSNotification *)notification
{
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    
    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey]intValue];
    
    if (self.bottomLayoutConstraint == nil) {
        
        CGRect originTableRect = self.tableView.frame;
        originTableRect.origin.y = 0;
        
        CGRect originBottomRect = [self.originInfoDict[@"bottomFrame"] CGRectValue];
        
        [UIView animateWithDuration:duration
                              delay:0
                            options:options
                         animations:^{
                             //让修改后的约束起作用
                             self.bottomView.frame = originBottomRect;
                             self.tableView.frame = originTableRect;
                             
                         } completion:^(BOOL finished) {
                             _originInfoDict = nil;
                             _targetViewController = nil;
                             _originTextField = nil;
                             _bottomLayoutConstraint = nil;
                             _tableView = nil;
                             _bottomView = nil;
                             CGRectIsEmpty(_originRect);
                             CGRectIsEmpty(_originBottomRect);
                             _indexPath = nil;
                             _originBottomLayout = nil;
                             _upOffsetY = 0.0f;
                             [[NSNotificationCenter defaultCenter] removeObserver:self];
                         }];
        
    } else {
    
        self.bottomLayoutConstraint.constant = [self.originInfoDict[@"bottomLayout"] floatValue];
    
        CGRect rect = self.originRect;
        rect.origin.y = 64;
    
        [UIView animateWithDuration:duration
                              delay:0
                            options:options
                         animations:^{
                             //让修改后的约束起作用
                             self.origrinView.frame = rect;
                         
                             [self.origrinView layoutIfNeeded];
                         
                         } completion:^(BOOL finished) {
                             _originInfoDict = nil;
                             _targetViewController = nil;
                             _originTextField = nil;
                             _bottomLayoutConstraint = nil;
                             _origrinView = nil;
                             _bottomView = nil;
                             CGRectIsEmpty(_originRect);
                             _originBottomLayout = nil;
                             _upOffsetY = 0.0f;
                             [[NSNotificationCenter defaultCenter] removeObserver:self];
                         }];
    }
    
}

@end
