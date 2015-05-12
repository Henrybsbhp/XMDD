//
//  MyOrderListVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MyOrderListVC.h"
#import "XiaoMa.h"
#import "CarwashOrderViewModel.h"
#import "InsranceOrderViewModel.h"

@interface MyOrderListVC ()
@property (nonatomic, strong) IBOutlet CarwashOrderViewModel *carwashModel;
@property (nonatomic, strong) IBOutlet InsranceOrderViewModel *insuranceModel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *carwashTabBtn;
@property (weak, nonatomic) IBOutlet UIButton *insuranceTabBtn;
@property (nonatomic, strong) CKSegmentHelper *segmentHelper;
@end

@implementation MyOrderListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.carwashModel.targetVC = self;
    self.insuranceModel.targetVC = self;
    [self setupTopView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTopView
{
    @weakify(self);
    self.segmentHelper = [CKSegmentHelper new];
    UIImage *img = [[UIImage imageNamed:@"me_btn_bg3"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 2, 0)];
    [self.carwashTabBtn setBackgroundImage:img forState:UIControlStateSelected];
    [self.segmentHelper addItem:self.carwashTabBtn forGroupName:@"TopView" withChangedBlock:^(UIButton *item, BOOL selected) {
        @strongify(self);
        item.selected = selected;
        self.carwashModel.tableView.hidden = !selected;
        if (selected && !self.carwashModel.orders) {
            [self.carwashModel reloadData];
        }
    }];
    
    [self.insuranceTabBtn setBackgroundImage:img forState:UIControlStateSelected];
    [self.segmentHelper addItem:self.insuranceTabBtn forGroupName:@"TopView" withChangedBlock:^(UIButton *item, BOOL selected) {
        @strongify(self);
        item.selected = selected;
        self.insuranceModel.tableView.hidden = !selected;
        if (selected && !self.insuranceModel.orders) {
            [self.insuranceModel reloadData];
        }
    }];
    [self.segmentHelper selectItem:self.carwashTabBtn];
}

#pragma mark - Action
- (IBAction)actionCarwash:(id)sender
{
    [self.segmentHelper selectItem:self.carwashTabBtn];

}

- (IBAction)actionInsurance:(id)sender
{
    [self.segmentHelper selectItem:self.insuranceTabBtn];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
