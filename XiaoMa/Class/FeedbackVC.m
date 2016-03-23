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

    //设置textView
    self.feedbackTextView.delegate = self;
    self.feedbackTextView.placeholderString = @"有什么建议或意见,欢迎您提供给我们,谢谢!";
    self.feedbackTextView.placeholderTextView.textColor = HEXCOLOR(@"#c5c5cb");
    
    //设置反馈按钮
    @weakify(self);
    [[self.feedbackTextView rac_textSignal] subscribeNext:^(NSString *x) {
        
        @strongify(self);
        self.bottomButton.enabled = self.feedbackTextView.text.length > 0 ;
    }];
}


-(void)textViewDidBeginEditing:(UITextView *)textView
{
    //首次编辑会执行两次？  LYW
    [MobClick event:@"rp323_1"];
}

- (IBAction)actionFeedback:(id)sender {
    [MobClick event:@"rp323_2"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        FeedbackOp *op = [FeedbackOp new];
        op.req_contactinfo = gAppMgr.myUser.userID;
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
    if ([UIScreen mainScreen].bounds.size.height <= 480) {
        return 116;
    }
    return 146;
}
@end
