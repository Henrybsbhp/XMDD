//
//  ValuationResultVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/17.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "ValuationResultVC.h"
#import "NSDate+DateForText.h"
#import "GetShareButtonOpV2.h"
#import "SocialShareViewController.h"
#import "ShareResponeManager.h"
#import "SecondCarValuationVC.h"
#import "GetCityInfoByNameOp.h"
#import "NSString+RectSize.h"

@interface ValuationResultVC ()

@property (weak, nonatomic)IBOutlet UITableView *tableView;

@property (assign, nonatomic)BOOL isPresenting;

@end

@implementation ValuationResultVC

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"ValuationResultVC dealloc~~~");
}


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)actionBack:(id)sender
{
    [MobClick event:@"aicheguzhijieguo" attributes:@{@"navi" : @"back"}];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark TableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0 || indexPath.row == 5) {
            return 12;
        }
        else if (indexPath.row == 1) {
            CGFloat height = [self.modelStr labelSizeWithWidth:(self.tableView.frame.size.width - 86) font:[UIFont systemFontOfSize:12]].height;
            return 40 + height;
        }
        else {
            return 23;
        }
    }
    else {
        if (indexPath.row == 0 || indexPath.row == 4) {
            return 12;
        }
        else if (indexPath.row == 1) {
            return 30;
        }
        else if (indexPath.row == 2) {
            return 170;
        }
        else if (indexPath.row == 3){
            return 25;
        }
        else {
            return 75;
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 0 || indexPath.row == 5) {
            cell = [self cardImgCellAtIndex:indexPath];
        }
        else if (indexPath.row == 1) {
            cell=[tableView dequeueReusableCellWithIdentifier:@"FirstHeaderCell"];
            UIImageView * logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
            UILabel * licensenoL = (UILabel *)[cell.contentView viewWithTag:1002];
            UILabel * brandL = (UILabel *)[cell.contentView viewWithTag:1003];
            
            [logoV setImageByUrl:self.logoUrl withType:ImageURLTypeOrigin defImage:@"avatar_default" errorImage:@"avatar_default"];
            licensenoL.text = self.evaluateOp.req_licenseno;
            brandL.text = self.modelStr;
            if (!IOSVersionGreaterThanOrEqualTo(@"8.0")) {
                brandL.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 86;
            }
        }
        else {
            cell = [self contentCellAtIndex:indexPath];
        }
    }
    else {
        if (indexPath.row == 0 || indexPath.row == 4) {
            cell = [self cardImgCellAtIndex:indexPath];
        }
        else if (indexPath.row == 1) {
            cell=[tableView dequeueReusableCellWithIdentifier:@"SecondHeaderCell"];
        }
        else if (indexPath.row == 2) {
            cell=[tableView dequeueReusableCellWithIdentifier:@"SecondContentCell"];
            
            UIImage * bubbleImg = [[UIImage imageNamed:@"val_bubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 5, 10, 5)];
            NSArray * pirceArr = [[NSArray alloc] initWithObjects:@(self.evaluateOp.rsp_normalPrice), @(self.evaluateOp.rsp_betterPrice), @(self.evaluateOp.rsp_bestPrice), nil];
            
            for (int i = 0; i < 3; i ++) {
                UIImageView * bubbleV = (UIImageView *)[cell.contentView viewWithTag:(1001 + i * 2)];
                UILabel * priceL = (UILabel *)[cell.contentView viewWithTag:(1002 + i * 2)];
                priceL.text = [NSString stringWithFormat:@"%.2f万", [[pirceArr safetyObjectAtIndex:i] floatValue]];
                bubbleV.image = bubbleImg;
            }
            UILabel * tipLabel = (UILabel *)[cell.contentView viewWithTag:1007];
            tipLabel.numberOfLines = 0;
            tipLabel.text = self.evaluateOp.rsp_tip;
            if (!IOSVersionGreaterThanOrEqualTo(@"8.0")) {
                tipLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 32;
            }
        }
        else if (indexPath.row == 3){
            cell=[tableView dequeueReusableCellWithIdentifier:@"SecondMoreCell"];
            UIButton * moreBtn = (UIButton *)[cell.contentView viewWithTag:1001];
            @weakify(self);
            [[[moreBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                /**
                 *  查看更多事件
                 */
                [MobClick event:@"aicheguzhijieguo" attributes:@{@"aicheguzhijieguo" : @"chakangengduo"}];
                @strongify(self);
                DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
                vc.url = self.evaluateOp.rsp_url;
                [self.navigationController pushViewController:vc animated:YES];
            }];
        }
        else {
            cell=[tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
            UIButton * shareBtn = (UIButton *)[cell.contentView viewWithTag:1001];
            UIButton * sallBtn = (UIButton *)[cell.contentView viewWithTag:1002];
            
            @weakify(self);
            [[[shareBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                @strongify(self)
                [self shareAction];
            }];
            
            [[[sallBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                @strongify(self)
                [self carSallAction];
            }];
        }
    }
    return cell;
}

- (UITableViewCell *)cardImgCellAtIndex:(NSIndexPath *)indexPath
{
    UITableViewCell * cell=[self.tableView dequeueReusableCellWithIdentifier:@"BackCardImageCell"];
    UIImageView * cardImgV = (UIImageView *)[cell.contentView viewWithTag:1001];
    NSString * imgString;
    
    if (indexPath.section == 0) {
        imgString = indexPath.row == 0 ? @"val_card_top1" : @"val_card_bottom1";
    }
    else {
        imgString = indexPath.row == 0 ? @"val_card_top2" : @"val_card_bottom2";
    }
    UIImage * cardImg = [UIImage imageNamed:imgString];
    cardImgV.image = [cardImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 30, 0, 30)];
    
    return cell;
}

- (UITableViewCell *)contentCellAtIndex:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"FirstContentCell"];
    UIImageView * imgV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel * titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel * contentL = (UILabel *)[cell.contentView viewWithTag:1003];
    NSString * imgStr;
    
    if (indexPath.row == 2) {
        imgStr = @"val_miles";
        titleL.text = @"行驶里程";
        contentL.text = [NSString stringWithFormat:@"%.2f万公里", self.evaluateOp.req_mile];
    }
    else if (indexPath.row == 3) {
        imgStr = @"val_time";
        titleL.text = @"购买时间";
        contentL.text = [self.evaluateOp.req_buydate dateFormatForYYMM];
    }
    else {
        imgStr = @"val_location";
        titleL.text = @"估值城市";
        if (self.cityName.length && ![self.cityName isEqualToString:self.provinceName])
        {
            contentL.text = [NSString stringWithFormat:@"%@/%@", self.provinceName, self.cityName];
        }
        else
        {
            contentL.text = [NSString stringWithFormat:@"%@", self.provinceName];
        }
        
    }
    imgV.image = [UIImage imageNamed:imgStr];
    return cell;
}

- (void)shareAction {
    [MobClick event:@"aicheguzhijieguo" attributes:@{@"aicheguzhijieguo" : @"fenxiang"}];
    [gToast showingWithText:@"分享信息拉取中..."];
    GetShareButtonOpV2 * op = [GetShareButtonOpV2 operation];
    op.pagePosition = ShareSceneValuation;
    @weakify(self);
    [[op rac_postRequest] subscribeNext:^(GetShareButtonOpV2 * op) {
        @strongify(self);
        [gToast dismiss];
        SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
        vc.sceneType = ShareSceneValuation;    //页面位置
        vc.btnTypeArr = op.rsp_shareBtns; //分享渠道数组
        NSMutableDictionary * otherDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.evaluateOp.rsp_sharecode, @"shareCode", nil];
        vc.otherInfo = otherDic;
        vc.mobBaseValue = @"aicheguzhijieguo";
        
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
        sheet.shouldCenterVertically = YES;
        if (!self.isPresenting) {
            self.isPresenting = YES;
            [MobClick event:@"fenxiangyemian" attributes:@{@"chuxian":@"aicheguzhijieguo"}];
            [sheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
                self.isPresenting = NO;
            }];
        }
        
        [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            [MobClick event:@"fenxiangyemian" attributes:@{@"quxiao":@"aicheguzhijieguo"}];
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        [vc setClickAction:^{
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        
    } error:^(NSError *error) {
        [gToast showError:@"分享信息拉取失败，请重试"];
    }];
}

- (void)carSallAction {
    [MobClick event:@"aicheguzhijieguo" attributes:@{@"aicheguzhijieguo" : @"yijianmaiche"}];
    GetCityInfoByNameOp * op = [GetCityInfoByNameOp operation];
    op.province = self.provinceName;
    op.city = self.cityName;
    [[op rac_postRequest] subscribeNext:^(GetCityInfoByNameOp * op) {
        if ([op.rsp_sellerCityId intValue] == 0) {
            
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"知道了" color:HEXCOLOR(@"#f39c12") clickBlock:nil];
            HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"抱歉，您所在的城市未开通此项服务，敬请期待" ActionItems:@[cancel]];
            [alert show];
            
        }
        else {
            SecondCarValuationVC * vc = [valuationStoryboard instantiateViewControllerWithIdentifier:@"SecondCarValuationVC"];
            vc.carid = self.carId;
            vc.sellercityid = op.rsp_sellerCityId;
            [self.navigationController pushViewController:vc animated:YES];
        }
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}

@end
