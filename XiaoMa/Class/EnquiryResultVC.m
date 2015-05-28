//
//  EnquiryResultVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/12.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "EnquiryResultVC.h"
#import "XiaoMa.h"
#import "SubmitInsuranceInfoVC.h"
#import "SimplePolicyInfoVC.h"
#import "HKInsurance.h"

@interface EnquiryResultVC ()

@end

@implementation EnquiryResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadWithInsurance:(NSArray *)insurances calculatorID:(NSString *)cid
{
    _insurances = insurances;
    _calculatorID = cid;
    [self.tableView reloadData];
    CKAsyncMainQueue(^{
        CGFloat height = [UIScreen mainScreen].bounds.size.height <= 480 ? 100 : 160;
        self.tableView.tableFooterView.frame = CGRectMake(0, 0, self.view.frame.size.width, height);
        //这么写是因为直接设置footerView的frame是不启作用的（苹果bug？），需要重新赋值一下
        self.tableView.tableFooterView = self.tableView.tableFooterView;
    });
}
#pragma mark - Action
- (IBAction)actionUploadInfomation:(id)sender
{
    SubmitInsuranceInfoVC *vc = [UIStoryboard vcWithId:@"SubmitInsuranceInfoVC" inStoryboard:@"Insurance"];
    vc.calculateID = self.calculatorID;
    vc.car = self.car;
    vc.shouldUpdateCar = self.shouldUpdateCar;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)actionGotoHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)actionMakeCall:(id)sender
{
    [gPhoneHelper makePhone:@"4007111111" andInfo:@"4007-111-111"];
}
#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return MIN(3 ,self.insurances.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UIImageView *bgV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *priceL = (UILabel *)[cell.contentView viewWithTag:1002];
    UIButton *detailB = (UIButton *)[cell.contentView viewWithTag:1003];
    HKInsurance *ins = [self.insurances safetyObjectAtIndex:indexPath.row];

    UIImage *bgImg = [UIImage imageNamed:[NSString stringWithFormat:@"ins_cell_bg%d", (int)(indexPath.row+1)]];
    bgImg = [bgImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 75, 0, 1)];
    bgV.image = bgImg;
    priceL.text = [NSString stringWithFormat:@"￥%d", (int)ins.premium];
    
    //查看详情
    detailB.backgroundColor = indexPath.row == 0 ? HEXCOLOR(@"#6B77AD") : indexPath.row == 1 ? HEXCOLOR(@"#7EB929") : HEXCOLOR(@"#FDAE0C");
    @weakify(self);
    [[[detailB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {
        @strongify(self);
        SimplePolicyInfoVC *vc = [UIStoryboard vcWithId:@"SimplePolicyInfoVC" inStoryboard:@"Insurance"];
        vc.policy = ins;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    return cell;
}


@end
