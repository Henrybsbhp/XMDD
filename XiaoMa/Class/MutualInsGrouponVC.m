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
#import "MutualInsGrouponSubVC.h"

@interface MutualInsGrouponVC ()
@property (nonatomic, weak) HKPopoverView *popoverMenu;
@property (nonatomic, strong) AddCloseAnimationButton *menuButton;
@property (weak, nonatomic) IBOutlet UIView *topSubView;
@property (nonatomic, weak) MutualInsGrouponSubVC *topSubVC;

@end

@implementation MutualInsGrouponVC

#pragma mark - System
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"史上最强团";
    [self setupNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (segue.identifier && [segue.identifier isEqualToString:@"MutualInsGrouponSubVC"]) {
        self.topSubVC = (MutualInsGrouponSubVC *)segue.destinationViewController;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.popoverMenu dismissWithAnimated:YES];
}
#pragma mark - Setup
- (void)setupNavigationBar
{
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    AddCloseAnimationButton *button = [[AddCloseAnimationButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    [button addTarget:self action:@selector(actionShowOrHideMenu:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:button];
    self.menuButton = button;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:container];
    [self.navigationItem setRightBarButtonItem:rightItem];
}

#pragma mark - Action
- (void)actionShowOrHideMenu:(id)sender
{
    BOOL closing = self.menuButton.closing;
    [self.menuButton setClosing:!closing WithAnimation:YES];
    if (closing && self.popoverMenu) {
        [self.popoverMenu dismissWithAnimated:YES];
    }
    else if (!closing && !self.popoverMenu) {
        HKPopoverViewItem *item1 = [HKPopoverViewItem itemWithTitle:@"邀请入团" imageName:@"mins_person"];
        HKPopoverViewItem *item2 = [HKPopoverViewItem itemWithTitle:@"退出该团" imageName:@"mins_exit"];
        HKPopoverView *popover = [[HKPopoverView alloc] initWithMaxWithContentSize:CGSizeMake(148, 160) items:@[item1,item2]];
        
        [popover setDidSelectedBlock:^(NSUInteger index) {
            
            if (index == 0)
            {
                
            }
            else
            {
                
            }
                
        }];
        @weakify(self);
        [popover setDidDismissedBlock:^(BOOL animated) {
            @strongify(self);
            [self.menuButton setClosing:NO WithAnimation:animated];
        }];
        [popover showAtAnchorPoint:CGPointMake(self.navigationController.view.frame.size.width-33, 60)
                            inView:self.navigationController.view dismissTargetView:self.view animated:YES];
        self.popoverMenu = popover;
    }
}

@end
