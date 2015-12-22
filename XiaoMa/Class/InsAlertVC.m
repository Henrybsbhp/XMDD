//
//  InsAlertVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/21.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "InsAlertVC.h"
#import "NSString+RectSize.h"

@interface InsAlertVC ()
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *ensureButton;

@end

@implementation InsAlertVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionDismiss:(id)sender
{
    [self.formSheetController dismissAnimated:YES completionHandler:nil];
}

+ (void)showInView:(UIView *)view withMessage:(NSString *)msg
{
    CGFloat lbh = ceil([msg labelSizeWithWidth:276 font:[UIFont systemFontOfSize:14]].height);
    CGSize size = CGSizeMake(300, MIN(440, MAX(94, lbh+75)));
    
    InsAlertVC *vc = [UIStoryboard vcWithId:@"InsAlertVC" inStoryboard:@"Insurance"];
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:size viewController:vc];
    sheet.cornerRadius = 0;
    sheet.shadowRadius = 0;
    sheet.shadowOpacity = 0;
    sheet.transitionStyle = MZFormSheetTransitionStyleDropDown;
    sheet.shouldDismissOnBackgroundViewTap = NO;
    [MZFormSheetController sharedBackgroundWindow].backgroundBlurEffect = NO;
    sheet.portraitTopInset = floor((view.frame.size.height - size.height) / 2);
    
    [sheet presentAnimated:YES completionHandler:nil];
    vc.messageLabel.text = msg;
    vc.view.layer.cornerRadius = 2;
    vc.view.layer.masksToBounds = YES;
}

@end
