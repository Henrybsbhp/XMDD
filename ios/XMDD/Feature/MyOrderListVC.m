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

@interface MyOrderListVC ()

@property (weak, nonatomic) IBOutlet UIButton *washBtn;
@property (weak, nonatomic) IBOutlet UIButton *insranceBtn;
@property (weak, nonatomic) IBOutlet UIButton *otherBtn;
@property (weak, nonatomic) IBOutlet UIView *underLineView;
@property (weak, nonatomic) IBOutlet UIView *underLineView2;
@property (weak, nonatomic) IBOutlet UIView *underLineView3;
@property (weak, nonatomic) IBOutlet JTTableView *carwashTableView;
@property (weak, nonatomic) IBOutlet JTTableView *insranceTableView;
@property (weak, nonatomic) IBOutlet JTTableView *otherTableView;
@property (nonatomic, strong) CarwashOrderViewModel *carwashModel;
@property (nonatomic, strong) InsranceOrderViewModel *insuranceModel;
@property (nonatomic, strong) OthersOrderViewModel *otherModel;
@property (nonatomic, strong) HKLoadingModel *loadingModel;
@property (nonatomic, assign) long long curTradetime;
@end

@implementation MyOrderListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.carwashModel = [[CarwashOrderViewModel alloc] initWithTableView:self.carwashTableView];
    self.insuranceModel = [[InsranceOrderViewModel alloc] initWithTableView:self.insranceTableView];
    self.otherModel = [[OthersOrderViewModel alloc] initWithTableView:self.otherTableView];
    [self.carwashModel resetWithTargetVC:self];
    [self.insuranceModel resetWithTargetVC:self];
    [self.otherModel resetWithTargetVC:self];
    [self.carwashModel.loadingModel loadDataForTheFirstTime];
    [self.insuranceModel.loadingModel loadDataForTheFirstTime];
    [self.otherModel.loadingModel loadDataForTheFirstTime];
    self.washBtn.selected = YES;
    @weakify(self);
    [[self.washBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [MobClick event:@"rp318_3"];
        self.washBtn.selected = YES;
        self.insranceBtn.selected = NO;
        self.otherBtn.selected = NO;
        self.carwashTableView.hidden = NO;
        self.insranceTableView.hidden = YES;
        self.otherTableView.hidden = YES;
        self.underLineView.hidden = NO;
        self.underLineView2.hidden = YES;
        self.underLineView3.hidden = YES;
    }];

    [[self.insranceBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        self.washBtn.selected = NO;
        self.insranceBtn.selected = YES;
        self.otherBtn.selected = NO;
        [MobClick event:@"rp318_4"];
        self.carwashTableView.hidden = YES;
        self.insranceTableView.hidden = NO;
        self.otherTableView.hidden = YES;
        self.underLineView.hidden = YES;
        self.underLineView2.hidden = NO;
        self.underLineView3.hidden = YES;
    }];
    
    [[self.otherBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        self.washBtn.selected = NO;
        self.insranceBtn.selected = NO;
        self.otherBtn.selected = YES;
        self.carwashTableView.hidden = YES;
        self.insranceTableView.hidden = YES;
        self.otherTableView.hidden = NO;
        self.underLineView.hidden = YES;
        self.underLineView2.hidden = YES;
        self.underLineView3.hidden = NO;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DebugLog(@"MyOrderListVC dealloc");
}

@end
