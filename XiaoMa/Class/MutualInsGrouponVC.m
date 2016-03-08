//
//  MutualInsGrouponVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGrouponVC.h"
#import "AddCloseAnimationButton.h"
#import "PullDownAnimationButton.h"
#import "HKPopoverView.h"

@interface MutualInsGrouponVC ()
@property (nonatomic, weak) HKPopoverView *popoverMenu;
@end

@implementation MutualInsGrouponVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.popoverMenu dismissWithAnimated:YES];
}

#pragma mark - Action
- (IBAction)actionClick:(id)sender {
    
    PullDownAnimationButton *btn = sender;
    [btn setPulled:!btn.pulled withAnimation:YES];
    [self actionShowMenu:nil];
}

- (void)actionShowMenu:(id)sender
{
    if (self.popoverMenu) {
        return;
    }
    HKPopoverViewItem *item1 = [HKPopoverViewItem itemWithTitle:@"邀请入团" imageName:@"mins_person"];
    HKPopoverViewItem *item2 = [HKPopoverViewItem itemWithTitle:@"退出该团" imageName:@"mins_exit"];
    HKPopoverView *popover = [[HKPopoverView alloc] initWithMaxWithContentSize:CGSizeMake(148, 160) items:@[item1,item2]];
    [popover showAtAnchorPoint:CGPointMake(300, 60) inView:self.navigationController.view animated:YES];
    self.popoverMenu = popover;
}

- (void)actionHideMenu:(id)sender
{
}

@end
