//
//  ShopDetailVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "ShopDetailVC.h"
#import "JTShop.h"
#import "XiaoMa.h"
#import <Masonry.h>
#import "JTRatingView.h"
#import "PayForWashCarVC.h"
#import "DistanceCalcHelper.h"
#import "NSDate+DateForText.h"
#import "GetShopRatesOp.h"
#import "CarWashNavigationViewController.h"

#define kDefaultServieCount     2

@interface ShopDetailVC ()

/// 服务列表展开
@property (nonatomic, assign) BOOL serviceExpanded;

@end

@implementation ShopDetailVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self requestShopComments];
}


//- (void)reloadDatasource
//{
//    JTShop *shop = [JTShop new];
//    shop.title = @"神州洗车";
//    shop.logoUrl = @"tmp_1";
//    shop.allowABC = @YES;
//    shop.allowTicket = @YES;
//    shop.rating = @4.0;
//    shop.openTime = @"8:00";
//    shop.closeTime = @"18:00";
//    shop.distance = @7.7;
//    shop.address = @"西湖区黄龙路1号沃尔玛超市二楼";
//    shop.phoneNumber = @"0571-88908888";
//
//    JTShopService *service1 = [JTShopService new];
//    service1.title = @"普洗：普通车";
//    service1.abcIntegral = @10000;
//    service1.oldPrice = @35;
//    service1.curPrice = @20;
//    service1.intro = @"车外冲洗，喷洒清洗剂，长枪冲水，车内清洗，擦干。";
//    
//    JTShopService *service2 = [JTShopService new];
//    service2.title = @"喷漆";
//    service2.intro = @"全车清洗，喷漆，打蜡。";
//    service2.curPrice = @180;
//    
//    JTShopService *service3 = [JTShopService new];
//    service3.title = @"保养";
//    service3.intro = @"更换机油机滤、刹车片、火花塞、电瓶、轮胎、雨刮等。";
//    service3.curPrice = @180;
//    
//    shop.services = @[service1, service2, service3];
//    
//    JTShopComment *comment1 = [JTShopComment new];
//    comment1.userName = @"超能陆战队";
//    comment1.time = @"2015.01.05";
//    comment1.avatarUrl = @"tmp_a1";
//    comment1.rating = @4;
//    comment1.content = @"第一次过来洗车，洗的很干净。老板服务态度很好";
//    
//    JTShopComment *comment2 = [JTShopComment new];
//    comment2.userName = @"陈大白";
//    comment2.time = @"2015.01.02";
//    comment2.avatarUrl = @"tmp_a2";
//    comment2.rating = @5;
//    comment2.content = @"洗的很仔细嘛，就给好评了";
//    shop.comments = @[comment1, comment2];
//    
//    self.serviceExpanded = (!self.serviceExpanded  && shop.services.count > 2) ? NO : YES;
//    self.shop = shop;
//    [self.tableView reloadData];
//}
#pragma mark - Action
- (void)requestShopComments
{
    GetShopRatesOp * op = [GetShopRatesOp operation];
    op.shopId = self.shop.shopID;
    op.pageno = 1;
    [[op rac_postRequest] subscribeNext:^(GetShopRatesOp * op) {
        
        self.shop.shopCommentArray = op.rsp_shopCommentArray;
        [self.tableView reloadData];
    }];
}


- (IBAction)actionMap:(id)sender
{
    
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            height = 84;
        }
        else if (indexPath.row == 1 || indexPath.row == 2) {
            height = 44;
        }
        else if (indexPath.row < 3+self.shop.shopServiceArray.count) {
            height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
        }
        else {
            height = 44;
        }
    }
    else {
        if (indexPath.row == 0) {
            height = 36;
        }
        else {
            height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
        }
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count = 0;
    if (section == 0) {
        count = self.serviceExpanded ? 3 + self.shop.shopServiceArray.count : ((3+MIN(kDefaultServieCount, self.shop.shopServiceArray.count)) + (self.shop.shopServiceArray.count > kDefaultServieCount ? 1 : 0));
    }
    else if (section == 1){
        count = 1+self.shop.shopCommentArray.count;
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [self shopTitleCellAtIndexPath:indexPath];
        }
        else if (indexPath.row == 1) {
            cell = [self shopAddrCellAtIndexPath:indexPath];
        }
        else if (indexPath.row == 2) {
            cell = [self shopPhoneNumberCellAtIndexPath:indexPath];
        }
        else
        {
            if (self.serviceExpanded)
            {
                cell = [self shopMoreServiceCellAtIndexPath:indexPath];
            }
            else
            {
                if (indexPath.row < 3+kDefaultServieCount ) {
                    cell = [self shopServiceCellAtIndexPath:indexPath];
                }
                else {
                    cell = [self shopMoreServiceCellAtIndexPath:indexPath];
                }
            }
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell = [self shopCommentTitleCellAtIndexPath:indexPath];
        }
        else {
            cell = [self shopCommentCellAtIndexPath:indexPath];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *jtcell = (JTTableViewCell *)cell;
    [jtcell prepareCellForTableView:tableView atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1)
        {
            CarWashNavigationViewController * vc = [[CarWashNavigationViewController alloc] init];
            vc.shop = self.shop;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (indexPath.row == 2)
        {
            if (self.shop.shopPhone.length == 0)
            {
                UIAlertView * av = [[UIAlertView alloc] initWithTitle:nil message:@"该店铺没有电话~" delegate:nil cancelButtonTitle:@"好吧" otherButtonTitles:nil];
                [av show];
                return ;
            }
            
            NSString * info = [NSString stringWithFormat:@"%@电话：\n%@",self.shop.shopName,self.shop.shopPhone];
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:nil message:info delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
            [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber *indexNum) {
                
                NSInteger index = [indexNum integerValue];
                if (index == 1)
                {
                    NSString * urlStr = [NSString stringWithFormat:@"tel://%@",self.shop.shopPhone];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
                }
            }];
            [av show];

        }
    }
}

#pragma mark - TableViewCell
- (UITableViewCell *)shopTitleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ShopTitleCell"];
    JTShop *shop = self.shop;
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    JTRatingView *ratingV = (JTRatingView *)[cell.contentView viewWithTag:1003];
    UILabel *ratingL = (UILabel *)[cell.contentView viewWithTag:1004];
    UILabel *businessHoursLb = (UILabel *)[cell.contentView viewWithTag:1005];
    UILabel *distantL = (UILabel *)[cell.contentView viewWithTag:1006];
    
    logoV.image = [UIImage imageNamed:@"tmp_ad"];
    titleL.text = shop.shopName;
    ratingV.ratingValue = (NSInteger)shop.shopRate;
    ratingL.text = [NSString stringWithFormat:@"%0.2f分", shop.shopRate];
    businessHoursLb.text = [NSString stringWithFormat:@"营业时间：%@ - %@",self.shop.openHour,self.shop.closeHour];
    
    double myLat = 30.254189;
    double myLng = 120.189234;
    double shopLat = shop.shopLatitude;
    double shopLng = shop.shopLongitude;
    NSString * disStr = [DistanceCalcHelper getDistanceStrLatA:myLat lngA:myLng latB:shopLat lngB:shopLng];
    distantL.text = disStr;

    
    return cell;
}

- (UITableViewCell *)shopAddrCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"AddrCell"];
    UILabel *label = (UILabel*)[cell.contentView viewWithTag:1001];
    UIButton *btn = (UIButton*)[cell.contentView viewWithTag:1002];
    
    label.text = self.shop.shopAddress;
    return cell;
}

- (UITableViewCell *)shopPhoneNumberCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PhoneNumberCell"];
    UILabel *label = (UILabel*)[cell.contentView viewWithTag:1001];
    UIButton *btn = (UIButton*)[cell.contentView viewWithTag:1002];
    
    label.text = [NSString stringWithFormat:@"联系电话：%@", self.shop.shopPhone];
    return cell;
}

- (UITableViewCell *)shopServiceCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ServiceCell"];
    UILabel *titleL = (UILabel*)[cell.contentView viewWithTag:1001];
    UIImageView *iconV = (UIImageView *)[cell.contentView viewWithTag:1002];
    UILabel *integralL = (UILabel *)[cell.contentView viewWithTag:1003];
    UILabel *priceL = (UILabel *)[cell.contentView viewWithTag:1004];
    UILabel *introL = (UILabel *)[cell.contentView viewWithTag:1005];
    UIButton *payB = (UIButton*)[cell.contentView viewWithTag:1006];
    
    JTShopService *service = [self.shop.shopServiceArray safetyObjectAtIndex:indexPath.row - 3];
    ChargeContent * cc;
    for (ChargeContent * tcc in service.chargeArray)
    {
        if (tcc.paymentChannelType == PaymentChannelABCIntegral )
        {
            cc = tcc;
            break;
        }
    }
    titleL.text = service.serviceName;
    iconV.hidden = !cc;
    integralL.hidden = !cc;
    integralL.text = [NSString stringWithFormat:@"%.0f分", cc.amount];
    [priceL mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(cc ? iconV : titleL);
    }];
    priceL.attributedText = [self priceStringWithOldPrice:@(service.origprice) curPrice:@(service.contractprice)];
    introL.text = service.serviceDescription;
    
    @weakify(self);
    [[[payB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        if([LoginViewModel loginIfNeededForTargetViewController:self]) {
            PayForWashCarVC *vc = [UIStoryboard vcWithId:@"PayForWashCarVC" inStoryboard:@"Carwash"];
            vc.originVC = self;
            vc.shop = self.shop;
            vc.service = service;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
    
    return cell;
}

- (UITableViewCell *)shopMoreServiceCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MoreServiceCell"];
    UIButton *btn = (UIButton *)[cell.contentView viewWithTag:1001];
    @weakify(self);
    [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        self.serviceExpanded = YES;
        [self.tableView reloadData];
    }];
    return cell;
}

- (UITableViewCell *)shopCommentTitleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CommentTitleCell"];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1001];
    label.text = [NSString stringWithFormat:@"商户评价 ( %d )", (NSInteger)self.shop.shopCommentArray.count];
    return cell;
}

- (UITableViewCell *)shopCommentCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    UIImageView *avatarV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *nameL = (UILabel*)[cell.contentView viewWithTag:1002];
    UILabel *timeL = (UILabel *)[cell.contentView viewWithTag:1003];
    JTRatingView *ratingV = (JTRatingView *)[cell.contentView viewWithTag:1004];
    UILabel *contentL = (UILabel *)[cell.contentView viewWithTag:1005];
    
    JTShopComment *comment = [self.shop.shopCommentArray safetyObjectAtIndex:indexPath.row - 1];
//    avatarV.image = [UIImage imageNamed:comment.avatarUrl];
    avatarV.image = [UIImage imageNamed:@"tmp_a1"];
    nameL.text = comment.nickname;
    timeL.text = [comment.time dateFormatForLongText];
    ratingV.ratingValue = comment.rate;
    contentL.text = comment.comment;
    
    return cell;
}

#pragma mark - Utility
- (NSAttributedString *)priceStringWithOldPrice:(NSNumber *)price1 curPrice:(NSNumber *)price2
{
    NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
    if (price1) {
        NSDictionary *attr1 = @{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)};
        NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%@", price1] attributes:attr1];
        [str appendAttributedString:attrStr1];
    }
    if (price2) {
        NSDictionary *attr2 = @{NSFontAttributeName:[UIFont systemFontOfSize:18],
                                NSForegroundColorAttributeName:HEXCOLOR(@"#f93a00")};
        NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" ￥%@", price2] attributes:attr2];
        [str appendAttributedString:attrStr2];
    }
    return str;
}

@end
