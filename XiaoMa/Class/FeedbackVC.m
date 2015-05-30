//
//  FeedbackVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/29.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "FeedbackVC.h"
#import <UIKitExtension.h>
#import "FeedbackOp.h"

@interface FeedbackVC ()
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIAPlaceholderTextView *feedbackTextView;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;

@end

@implementation FeedbackVC

- (void)viewDidLoad {
    [super viewDidLoad];

    //设置textView
    self.feedbackTextView.placeholderString = @"有什么建议或意见,欢迎您提供给我们,谢谢!";
    self.feedbackTextView.placeholderTextView.textColor = HEXCOLOR(@"#c5c5cb");
    
    //设置反馈按钮
    @weakify(self);
    [[[self.phoneTextField rac_textSignal] merge:[self.feedbackTextView rac_textSignal]] subscribeNext:^(NSString *x) {
        
        @strongify(self);
        self.bottomButton.enabled = self.phoneTextField.text.length > 0 && self.feedbackTextView.text.length > 0;
    }];
}


- (IBAction)actionFeedback:(id)sender {
    FeedbackOp *op = [FeedbackOp new];
    op.req_contactinfo = self.phoneTextField.text;
    op.req_feedback = self.feedbackTextView.text;
    
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"正在提交反馈..."];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [gToast showSuccess:@"提交成功!"];
        [self.navigationController popViewControllerAnimated:YES];
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}

@end
