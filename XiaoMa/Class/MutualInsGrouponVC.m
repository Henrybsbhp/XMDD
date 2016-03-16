//
//  MutualInsGrouponVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGrouponVC.h"
#import "AddCloseAnimationButton.h"
#import "HKPopoverView.h"

#import "MutualInsGrouponSubVC.h"
#import "MutualInsGrouponSubMsgVC.h"

#import "ExitCooperationOp.h"
#import "MutualInsHomeVC.h"

@interface MutualInsGrouponVC ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (nonatomic, weak) HKPopoverView *popoverMenu;
@property (nonatomic, strong) AddCloseAnimationButton *menuButton;
@property (nonatomic, strong) MutualInsGrouponSubVC *topSubVC;
@property (nonatomic, strong) MutualInsGrouponSubMsgVC *bottomSubVC;

@property (nonatomic, assign) BOOL isExpandingOrClosing;

@end

@implementation MutualInsGrouponVC

#pragma mark - System
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"史上最强团";
    [self setupNavigationBar];
    [self setupTopSubVC];
    CKAsyncMainQueue(^{
        [self reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.popoverMenu dismissWithAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (!segue.identifier) {
        return;
    }
    if ([segue.identifier isEqualToString:@"MutualInsGrouponSubVC"]) {
        self.topSubVC = (MutualInsGrouponSubVC *)segue.destinationViewController;
    }
    else if ([segue.identifier isEqualToString:@"MutualInsGrouponSubMsgVC"]) {
        self.bottomSubVC = (MutualInsGrouponSubMsgVC *)segue.destinationViewController;
    }
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

- (void)setupTopSubVC
{
    @weakify(self);
    [self.topSubVC setShouldExpandedOrClosed:^(BOOL expanded) {
        @strongify(self);
        [self setExpanded:expanded animated:YES];
    }];
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
                [self requestExitGroup];
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

#pragma mark - Reload
- (void)reloadData
{
    [self.topSubVC reloadDataWithStatus:MutInsStatusToBePaid];
    [self.bottomSubVC reloadData];
    @weakify(self);
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.height.mas_equalTo(self.topSubVC.expandedHeight);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.height.mas_equalTo(self.scrollView.frame.size.height - self.topSubVC.closedHeight);
    }];
}

- (void)setExpanded:(BOOL)expanded animated:(BOOL)animated
{
    self.isExpandingOrClosing = YES;
    self.topSubVC.isExpanded = expanded;
    CGFloat dvalue = (self.topSubVC.expandedHeight - self.topSubVC.closedHeight);
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.scrollView.contentOffset = CGPointMake(0, expanded ? 0 : dvalue);
        } completion:^(BOOL finished) {
            self.isExpandingOrClosing = NO;
            self.topSubVC.shouldStopWaveView = !expanded;
        }];
    }
    else {
        self.scrollView.contentOffset = CGPointMake(0, expanded ? 0 : dvalue);
        self.isExpandingOrClosing = NO;
        self.topSubVC.shouldStopWaveView = !expanded;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat dvalue = (self.topSubVC.expandedHeight - self.topSubVC.closedHeight);
    if (self.scrollView.contentOffset.y < dvalue/2 && !self.topSubVC.isExpanded) {
        [self setExpanded:YES animated:YES];
    }
    else if (self.scrollView.contentOffset.y > dvalue/2 && self.topSubVC.isExpanded) {
        [self setExpanded:NO animated:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat dvalue = (self.topSubVC.expandedHeight - self.topSubVC.closedHeight);
    if (!decelerate && self.scrollView.contentOffset.y < dvalue/2 && self.scrollView.contentOffset.y > 0) {
        [self setExpanded:YES animated:YES];
    }
    else if (!decelerate && self.scrollView.contentOffset.y > dvalue/2 && self.scrollView.contentOffset.y < dvalue) {
        [self setExpanded:NO animated:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat dvalue = (self.topSubVC.expandedHeight - self.topSubVC.closedHeight);
    if (!self.isExpandingOrClosing && self.scrollView.contentOffset.y < dvalue/2 && self.scrollView.contentOffset.y > 0) {
        [self setExpanded:YES animated:YES];
    }
    else if (!self.isExpandingOrClosing && self.scrollView.contentOffset.y > dvalue/2 && self.scrollView.contentOffset.y < dvalue) {
        [self setExpanded:NO animated:YES];
    }
}
#pragma mark - Utility
- (void)requestExitGroup
{
    ExitCooperationOp * op = [[ExitCooperationOp alloc] init];
    op.req_memberid = self.group.memberId;
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"退团中..."];
    }] subscribeNext:^(ExitCooperationOp * rop) {
        
        [gToast dismiss];
        for (UIViewController * vc in self.navigationController.viewControllers)
        {
            if ([vc isKindOfClass:NSClassFromString(@"MutualInsHomeVC")])
            {
                
                [self.navigationController popToViewController:vc animated:YES];
                [((MutualInsHomeVC *)vc) requestMyGourpInfo];
                return ;
            }
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

@end

