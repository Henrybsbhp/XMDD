//
//  CouponDetailsVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/9/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CouponDetailsVC.h"
#import "GetCouponDetailsOp.h"
#import "SocialShareViewController.h"
#import "ShareUserCouponOp.h"

@interface CouponDetailsVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong ,nonatomic) HKCoupon * couponDic;
@property (weak, nonatomic) IBOutlet UIButton *longUseBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *shortUseBtn;

@end

@implementation CouponDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUI];
    
    if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
    {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44;
    }
    [self requestDate];
}

- (void)setUI{
    
    if (self.isShareble) {
        self.longUseBtn.hidden = YES;
        [self.shortUseBtn setCornerRadius:5.0f];
        [[self.shortUseBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
        }];
        [self.shareBtn setCornerRadius:5.0f];
        [[self.shareBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            //转赠
            [self shareAction:self.couponId];
        }];
    }
    else {
        self.shortUseBtn.hidden = YES;
        self.shareBtn.hidden = YES;
        [self.longUseBtn setCornerRadius:5.0f];
        [[self.longUseBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
        }];
    }
}

- (void)requestDate {
    GetCouponDetailsOp * op = [GetCouponDetailsOp operation];
    op.req_cid = self.couponId;
    [[op rac_postRequest] subscribeNext:^(GetCouponDetailsOp * op) {
        self.couponDic = op.rsp_couponDetails;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark - Share
- (void)requestShareCoupon:(NSNumber *)cid
{
    ShareUserCouponOp * op = [ShareUserCouponOp operation];
    op.cid = cid;
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"分享信息获取中..."];
    }] subscribeNext:^(ShareUserCouponOp * sop) {
        
        [gToast dismiss];
        [self shareAction:sop andImage:nil];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

- (void)shareAction:(NSNumber *)cid
{
    [MobClick event:@"rp304-3"];
    
    [self requestShareCoupon:cid];
}

- (void)shareAction:(ShareUserCouponOp *)op andImage:(UIImage *)image
{
    SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
    vc.tt = op.rsp_title;
    vc.subtitle = op.rsp_content;
    vc.image = [UIImage imageNamed:@"wechat_share_coupon"];
    vc.webimage = [UIImage imageNamed:@"weibo_share_carwash"];
    vc.urlStr = op.rsp_linkUrl;
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
    sheet.shouldCenterVertically = YES;
    [sheet presentAnimated:YES completionHandler:nil];
    
    [vc setFinishAction:^{
        [sheet dismissAnimated:YES completionHandler:nil];
    }];
    
    [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [MobClick event:@"rp110-7"];
        [sheet dismissAnimated:YES completionHandler:nil];
    }];
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"使用流程";
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = CGFLOAT_MIN;
    if (section == 1) {
        height = 40;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return self.couponDic.useguide.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 130;
    }
    else
    {
        if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
        {
            return UITableViewAutomaticDimension;
        }
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        [cell layoutIfNeeded];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
        return ceil(size.height+1);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"HeadCell"];
        //背景图片
        UILabel * nameLabel = (UILabel *)[cell.contentView viewWithTag:1001];
        UILabel * subnameLabel = (UILabel *)[cell.contentView viewWithTag:1002];
        UILabel * describeLabel = (UILabel *)[cell.contentView viewWithTag:1003];
        UILabel * validDate = (UILabel *)[cell.contentView viewWithTag:1004];
        UIImageView * bgImageView = (UIImageView *)[cell.contentView viewWithTag:1005];
        
        nameLabel.text = self.couponDic.couponName;
        subnameLabel.text = [NSString stringWithFormat:@"（%@）", self.couponDic.subname];
        describeLabel.text = [NSString stringWithFormat:@"使用说明：%@", self.couponDic.couponDescription];
        validDate.text = [NSString stringWithFormat:@"有效期：%@ - %@", [self.couponDic.validsince dateFormatForYYMMdd2], [self.couponDic.validthrough dateFormatForYYMMdd2]];
        UIImage * bgImg = [[UIImage imageNamed:@"coupon_detailsbg"] imageByFilledWithColor:[UIColor colorWithHex:[NSString stringWithFormat:@"#%@", self.rgbStr] alpha:1.0f]];
        bgImageView.image = bgImg;
        
        return cell;
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"GuideCell"];
        UILabel * nolabel = (UILabel *)[cell.contentView viewWithTag:1001];
        UILabel * contentlabel = (UILabel *)[cell.contentView viewWithTag:1002];
        
        nolabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1];
        nolabel.layer.cornerRadius = 8.0f;
        nolabel.backgroundColor = [UIColor colorWithHex:[NSString stringWithFormat:@"#%@", self.rgbStr] alpha:1.0f];
        [nolabel.layer setMasksToBounds:YES];
        
        contentlabel.attributedText = [self setLabelContent:[self.couponDic.useguide safetyObjectAtIndex:indexPath.row]];
        
        return cell;
    }
}

- (NSMutableAttributedString *) setLabelContent:(NSString *) contentStr
{
    //设置行间距、居中等
    NSMutableAttributedString * attributedStr = [[NSMutableAttributedString alloc] initWithString:contentStr];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8.0f;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    [attributedStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, contentStr.length)];
    return attributedStr;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end
