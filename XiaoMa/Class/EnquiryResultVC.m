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
#import "InsuranceAppointmentOp.h"
#import "InsuranceDetailPlanVC.h"

@interface EnquiryResultVC ()

@end

@implementation EnquiryResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc
{
    DebugLog(@"EnquiryResultVC dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp116"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp116"];
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
    [MobClick event:@"rp116-4"];
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
    [MobClick event:@"rp116-5"];
    [gPhoneHelper makePhone:@"4007111111" andInfo:@"4007-111-111"];
}
#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [MobClick event:@"rp116-1"];
    }
    else if (indexPath.section == 1) {
        [MobClick event:@"rp116-2"];
    }
    else if (indexPath.section == 2) {
        [MobClick event:@"rp116-3"];
    }
    
    //预约购买接口试调
    
//    InsuranceAppointmentOp * op = [InsuranceAppointmentOp operation];
//    op.req_licencenumber = @"浙A12312";
//    op.req_city = @"杭州市";
//    op.req_register = 1;
//    op.req_purchaseprice = 123.2;
//    op.req_purchasedate = [NSDate date];
//    op.req_phone = @"15869163784";
//    op.req_idcard = @"341281199309230656";
//    op.req_idpic = @"http://a.hiphotos.baidu.com/zhidao/pic/item/7e3e6709c93d70cff39269d0f9dcd100bba12b87.jpg";
//    op.req_driverpic = @"http://a.hiphotos.baidu.com/zhidao/pic/item/7e3e6709c93d70cff39269d0f9dcd100bba12b87.jpg";
//    op.req_inslist = @"1@车损险@1.4万";
//    
//    [[op rac_postRequest] subscribeNext:^(id x) {
//        
//    } error:^(NSError *error) {
//        
//    }];
 
    InsuranceDetailPlanVC * vc = [insuranceStoryboard instantiateViewControllerWithIdentifier:@"InsuranceDetailPlanVC"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 11;
    }
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MIN(3, self.insurances.count);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UIImageView *bgV = (UIImageView *)[cell.contentView viewWithTag:1000];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *priceL = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *subTitleL = (UILabel *)[cell.contentView viewWithTag:1003];
    UIView *detailV = [cell.contentView viewWithTag:1004];
    UILabel *detailTitleL = (UILabel *)[detailV viewWithTag:10041];
    UIImageView *detailArrowV = (UIImageView *)[detailV viewWithTag:10042];
    
    HKInsurance *ins = [self.insurances safetyObjectAtIndex:indexPath.row];

    UIImage *bgImg = [UIImage imageNamed:[NSString stringWithFormat:@"ins_cell_bg%d", (int)(indexPath.section+1)]];
    bgImg = [bgImg resizableImageWithCapInsets:UIEdgeInsetsMake(45, 11, 6, 12)];
    bgV.image = bgImg;
    
    priceL.text = [NSString stringWithFormat:@"￥%d", (int)ins.premium];
    
    detailV.layer.borderWidth = 1;
    detailV.layer.cornerRadius = 4.0;
    detailV.layer.masksToBounds = YES;
    if (indexPath.section == 0) {
        titleL.text = @"平民套餐";
        subTitleL.text = @"广大人民的选择";
        detailV.layer.borderColor = [HEXCOLOR(@"#1bb745") CGColor];
        detailTitleL.textColor = HEXCOLOR(@"#1bb745");
        detailArrowV.image = [UIImage imageNamed:@"ins_arrow1"];
    }
    else if (indexPath.section == 1) {
        titleL.text = @"土豪风范";
        subTitleL.text = @"对爱车好一点，让车主更安心";
        detailV.layer.borderColor = [HEXCOLOR(@"#8054b2") CGColor];
        detailTitleL.textColor = HEXCOLOR(@"#8054b2");;
        detailArrowV.image = [UIImage imageNamed:@"ins_arrow2"];
    }
    else if (indexPath.section == 2) {
        titleL.text = @"自选车险";
        subTitleL.text = @"我的车险我做主";
        detailV.layer.borderColor = [HEXCOLOR(@"#3d98ff") CGColor];
        detailTitleL.textColor = HEXCOLOR(@"#3d98ff");
        detailArrowV.image = [UIImage imageNamed:@"ins_arrow3"];
    }
    
    return cell;
}


@end
