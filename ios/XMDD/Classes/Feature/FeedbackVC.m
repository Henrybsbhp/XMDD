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

@interface FeedbackVC () <UITextViewDelegate>
//@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *contactField;
@property (weak, nonatomic) IBOutlet UIAPlaceholderTextView *feedbackTextView;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;

@end

@implementation FeedbackVC
- (void)dealloc
{
    DebugLog(@"FeedbackVC dealloc!");
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //设置textField
    self.contactField.placeholder = @"请输入联系方式，如手机号、qq、email";
    
    @weakify(self);
    [[RACObserve(gAppMgr, myUser) distinctUntilChanged] subscribeNext:^(id x) {
        
        @strongify(self);
        if (gAppMgr.myUser.phoneNumber) {
            self.contactField.text = gAppMgr.myUser.phoneNumber;
        }
    }];
    
    //设置textView
    self.feedbackTextView.delegate = self;
    self.feedbackTextView.placeholderString = @"有什么建议或意见,欢迎您提供给我们,谢谢!";
    self.feedbackTextView.placeholderTextView.textColor = HEXCOLOR(@"#c5c5cb");
    
    //设置反馈按钮
    [[self.feedbackTextView rac_textSignal] subscribeNext:^(NSString *x) {
        
        @strongify(self);
        if (self.feedbackTextView.text.length > 0) {
            self.bottomButton.enabled = YES;
            [self.bottomButton setBackgroundColor:kDefTintColor];
        }
        else {
            self.bottomButton.enabled = NO;
            [self.bottomButton setBackgroundColor:kLightLineColor];
        }
        
    }];
}


-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [MobClick event:@"rp323_1"];
}

- (IBAction)actionFeedback:(id)sender {
    [MobClick event:@"rp323_2"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        FeedbackOp *op = [FeedbackOp new];
        op.req_contactinfo = self.contactField.text.length ? self.contactField.text : gAppMgr.myUser.userID;
        op.req_feedback = self.feedbackTextView.text;
        
        @weakify(self);
        [[[op rac_postRequest] initially:^{
            
            [gToast showingWithText:@"正在提交反馈..."];
        }] subscribeNext:^(id x) {
            
            @strongify(self);
            [gToast showSuccess:@"反馈成功，您的意见是我们宝贵的财富"];
            [self.navigationController popViewControllerAnimated:YES];
        } error:^(NSError *error) {
            [gToast showError:error.domain];
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 90;
    }
    return 150;
}
@end
