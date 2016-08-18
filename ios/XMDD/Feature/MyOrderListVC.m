//
//  MyOrderListVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MyOrderListVC.h"
#import "Xmdd.h"
#import "GetCarwashOrderListV3Op.h"
#import "CarwashOrderDetailVC.h"
#import "CarwashOrderViewModel.h"
#import "InsranceOrderViewModel.h"
#import "OthersOrderViewModel.h"
#import "HKLoadingModel.h"
#import "HorizontalScrollTabView.h"
#import "MutualOrderViewModel.h"
#import "GasOrderModelView.h"
#import "MaintainOrderViewModel.h"

@interface MyOrderListVC ()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic, strong) HorizontalScrollTabView *tabView;
@property (weak, nonatomic) IBOutlet JTTableView *carwashTableView;
@property (weak, nonatomic) IBOutlet JTTableView *maintainTableView;
@property (weak, nonatomic) IBOutlet JTTableView *gasTableView;
@property (weak, nonatomic) IBOutlet JTTableView *mutualTableView;
@property (weak, nonatomic) IBOutlet JTTableView *insranceTableView;
@property (weak, nonatomic) IBOutlet JTTableView *otherTableView;
@property (nonatomic, strong) MaintainOrderViewModel *maintainModel;
@property (nonatomic, strong) GasOrderModelView *gasModel;
@property (nonatomic, strong) MutualOrderViewModel *mutualModel;
@property (nonatomic, strong) InsranceOrderViewModel *insuranceModel;
@property (nonatomic, strong) OthersOrderViewModel *otherModel;
@property (nonatomic, strong) HKLoadingModel *loadingModel;
@property (nonatomic, assign) long long curTradetime;
@end

@implementation MyOrderListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.maintainModel = [[MaintainOrderViewModel alloc] initWithTableView:self.maintainTableView];
    self.gasModel = [[GasOrderModelView alloc] initWithTableView:self.gasTableView];
    self.mutualModel = [[MutualOrderViewModel alloc] initWithTableView:self.mutualTableView];
    self.insuranceModel = [[InsranceOrderViewModel alloc] initWithTableView:self.insranceTableView];
    self.otherModel = [[OthersOrderViewModel alloc] initWithTableView:self.otherTableView];
    
    [self.maintainModel resetWithTargetVC:self];
    [self.gasModel resetWithTargetVC:self];
    [self.mutualModel resetWithTargetVC:self];
    [self.insuranceModel resetWithTargetVC:self];
    [self.otherModel resetWithTargetVC:self];
    
    [self.maintainModel.loadingModel loadDataForTheFirstTime];
    [self.gasModel.loadingModel loadDataForTheFirstTime];
    [self.mutualModel.loadingModel loadDataForTheFirstTime];
    [self.insuranceModel.loadingModel loadDataForTheFirstTime];
    [self.otherModel.loadingModel loadDataForTheFirstTime];
    
    self.tabView = [[HorizontalScrollTabView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.tabView.scrollTipBarColor = kDefTintColor;
    HorizontalScrollTabItem *maintainItem = [HorizontalScrollTabItem itemWithTitle:@"养护" normalColor:kDarkTextColor selectedColor:kDefTintColor];
    HorizontalScrollTabItem *gasItem = [HorizontalScrollTabItem itemWithTitle:@"加油" normalColor:kDarkTextColor selectedColor:kDefTintColor];
    HorizontalScrollTabItem *mutualItem = [HorizontalScrollTabItem itemWithTitle:@"互助" normalColor:kDarkTextColor selectedColor:kDefTintColor];
    HorizontalScrollTabItem *insuranceItem = [HorizontalScrollTabItem itemWithTitle:@"保险" normalColor:kDarkTextColor selectedColor:kDefTintColor];
    HorizontalScrollTabItem *otherItem = [HorizontalScrollTabItem itemWithTitle:@"其他" normalColor:kDarkTextColor selectedColor:kDefTintColor];
    self.tabView.items = @[maintainItem, gasItem, mutualItem, insuranceItem, otherItem];
    [self.headerView addSubview:self.tabView];
    
    @weakify(self);
    [self.tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.headerView);
        make.right.equalTo(self.headerView);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(self.headerView);
    }];
    
    [self.tabView setTabBlock:^(NSInteger index) {
        @strongify(self);
        if (index == 0) {
            
            [MobClick event:@"dingdan" attributes:@{@"dingdan" : @"dingdan2"}];
            self.maintainTableView.hidden = NO;
            self.carwashTableView.hidden = YES;
            self.gasTableView.hidden = YES;
            self.mutualTableView.hidden = YES;
            self.insranceTableView.hidden = YES;
            self.otherTableView.hidden = YES;
            
        } else if (index == 1) {
            
            [MobClick event:@"dingdan" attributes:@{@"dingdan" : @"dingdan3"}];
            self.gasTableView.hidden = NO;
            self.maintainTableView.hidden = YES;
            self.mutualTableView.hidden = YES;
            self.carwashTableView.hidden = YES;
            self.insranceTableView.hidden = YES;
            self.otherTableView.hidden = YES;
            
        } else if (index == 2) {
            
            [MobClick event:@"dingdan" attributes:@{@"dingdan" : @"dingdan4"}];
            self.mutualTableView.hidden = NO;
            self.maintainTableView.hidden = YES;
            self.carwashTableView.hidden = YES;
            self.insranceTableView.hidden = YES;
            self.otherTableView.hidden = YES;
            self.gasTableView.hidden = YES;
            
        } else if (index == 3) {
            
            [MobClick event:@"dingdan" attributes:@{@"dingdan" : @"dingdan5"}];
            self.carwashTableView.hidden = YES;
            self.gasTableView.hidden = YES;
            self.mutualTableView.hidden = YES;
            self.maintainTableView.hidden = YES;
            self.insranceTableView.hidden = NO;
            self.otherTableView.hidden = YES;
            
        } else {
            
            [MobClick event:@"dingdan" attributes:@{@"dingdan" : @"dingdan6"}];
            self.maintainTableView.hidden = YES;
            self.carwashTableView.hidden = YES;
            self.mutualTableView.hidden = YES;
            self.gasTableView.hidden = YES;
            self.insranceTableView.hidden = YES;
            self.otherTableView.hidden = NO;
            
        }
    }];
    
    [self.tabView reloadDataWithBoundsSize:CGSizeMake(ScreenWidth, 44) andSelectedIndex:self.tabViewSelectedIndex];
}

- (void)setTabViewSelectedIndex:(NSInteger)tabViewSelectedIndex
{
    _tabViewSelectedIndex = tabViewSelectedIndex;
    [self.tabView setSelectedIndex:tabViewSelectedIndex animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [MobClick event:@"dingdan" attributes:@{@"dingdan" : @"dingdan1"}];
    DebugLog(@"MyOrderListVC dealloc");
}

@end
