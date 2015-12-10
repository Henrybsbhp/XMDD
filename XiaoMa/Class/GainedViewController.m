//
//  GainedViewController.m
//  XiaoMa
//
//  Created by jt on 15-6-12.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GainedViewController.h"
#import "MyCouponVC.h"
#import "SocialShareViewController.h"
#import "UIBarButtonItem+CustomStyle.h"
#import "ShareResponeManager.h"
#import "AwardOtherSheetVC.h"
#import "CarWashTableVC.h"
#import "SharedNotifyOp.h"
#import "GetShareButtonOp.h"

@interface GainedViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *awardBgView;
@property (weak, nonatomic) IBOutlet UILabel *awardLb;

@property (nonatomic, assign)BOOL isPresenting;

@end

@implementation GainedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp402"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp402"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DebugLog(@"GainedViewController dealloc");
}

- (void)setupNavigationBar
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack)];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)actionBack
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger width = (NSInteger)[[UIScreen mainScreen] bounds].size.width;
    CGFloat height;
    switch (width) {
        case 320:
            height = 506;
            break;
        case 375:
            height = 606;
            break;
        case 414:
            height = 674;
            break;
            
        default:
            height = 504;
            break;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainCell" forIndexPath:indexPath];
    
    UIImageView * bgView = (UIImageView *)[cell searchViewWithTag:101];
    UILabel * leftDayLb = (UILabel *)[cell searchViewWithTag:102];
    UIImageView * couponBgView = (UIImageView *)[cell searchViewWithTag:20301];
    UILabel * amountLb = (UILabel *)[cell searchViewWithTag:20302];
    UIImageView * usedView = (UIImageView *)[cell searchViewWithTag:20303];
    UIButton * checkCouponBtn = (UIButton *)[cell searchViewWithTag:104];
    UIButton * shareBtn = (UIButton *)[cell searchViewWithTag:105];
    //UILabel * noteLb = (UILabel *)[cell searchViewWithTag:106];
    
    NSInteger deviceWidth = (NSInteger)[[UIScreen mainScreen] bounds].size.width;
    NSString * imageName = [NSString stringWithFormat:@"award_bg_%ld",(long)deviceWidth];
    bgView.image = [UIImage imageNamed:imageName];
    
    UIImage * bgImg = [(self.isCouponUsed ? [UIImage imageNamed:@"award_coupon_used_bg"] : [UIImage imageNamed:@"award_coupon_bg"]) resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 100)];
    couponBgView.image = bgImg;
    
    shareBtn.hidden = !gAppMgr.canShareFlag;
    usedView.hidden = !self.isCouponUsed;
    amountLb.textColor = self.isCouponUsed ? [UIColor whiteColor] : [UIColor colorWithHex:@"#e7473e" alpha:1.0f];
    
    if (self.leftDay > 0){
        leftDayLb.text = [NSString stringWithFormat:@"您已领取礼券，%ld天后再来领取吧！",(long)self.leftDay];
    }
    else{
        leftDayLb.text = [NSString stringWithFormat:@"%@",self.tip];
    }
    
    amountLb.attributedText = [self attributeString:(long)self.amount];
    
    @weakify(self);
    [[[checkCouponBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self)
        [MobClick event:@"rp402-1"];
        MyCouponVC *vc = [mineStoryboard instantiateViewControllerWithIdentifier:@"MyCouponVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    [[[shareBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self)
        [self shareAction];
    }];
    
    return cell;
}

#pragma mark - Utility
- (NSAttributedString *)attributeString:(NSInteger)a
{
    NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
    NSDictionary *attr1 = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:27]};
    NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:
                                    @"洗车代金券" attributes:attr1];
    [str appendAttributedString:attrStr1];
    
    NSDictionary *attr2 = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:40]};
    NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:
                                    [NSString stringWithFormat:@"%ld",self.amount] attributes:attr2];
    [str appendAttributedString:attrStr2];
    
    NSDictionary *attr3 = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:27]};
    NSAttributedString *attrStr3 = [[NSAttributedString alloc] initWithString:
                                    @"元" attributes:attr3];
    [str appendAttributedString:attrStr3];
    
    return str;
}

- (void)shareAction
{
    [MobClick event:@"rp402-2"];
    GetShareButtonOp * op = [GetShareButtonOp operation];
    op.pagePosition = ShareSceneGain;
    @weakify(self);
    [[op rac_postRequest] subscribeNext:^(GetShareButtonOp * op) {
        
        SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
        vc.sceneType = ShareSceneGain;    //页面位置
        vc.btnTypeArr = op.rsp_shareBtns; //分享渠道数组
        
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
        sheet.shouldCenterVertically = YES;
        if (!self.isPresenting) {
            self.isPresenting = YES;
            [sheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
                self.isPresenting = NO;
            }];
        }
            
        [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [MobClick event:@"rp110-7"];
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        [vc setClickAction:^{
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        
        [[ShareResponeManager init] setFinishAction:^(NSInteger code, ShareResponseType type){
            
            @strongify(self)
            [self handleResultCode:code from:type forSheet:sheet];
        }];
        [[ShareResponeManagerForQQ init] setFinishAction:^(NSString * code, ShareResponseType type){
            
            @strongify(self)
            [self handleResultCode:[code integerValue] from:type forSheet:sheet];
        }];
    } error:^(NSError *error) {
        
    }];
}

- (void)handleResultCode:(NSInteger)code from:(ShareResponseType)type forSheet:(MZFormSheetController *)sheet
{
    @weakify(self);
    [sheet dismissAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        if (code == 0) {
            SharedNotifyOp * op = [SharedNotifyOp operation];
            [gToast showingWithoutText];
            [[op rac_postRequest] subscribeNext:^(SharedNotifyOp * op) {
                
                @strongify(self);
                [gToast dismiss];
                if (op.rsp_flag == AwardSheetTypeSuccess) {
                    [self presentSheet:AwardSheetTypeSuccess];
                }
                else {
                    [self presentSheet:AwardSheetTypeAlreadyget];
                }
            } error:^(NSError *error) {
                [gToast dismiss];
            }];
        }
        else if (type ==ShareResponseWechat && code == -2) {
            [self presentSheet:AwardSheetTypeCancel];
        }
        else if (type == ShareResponseWeibo && code == -1) {
            [self presentSheet:AwardSheetTypeCancel];
        }
        else if (type == ShareResponseQQ && code == -4) {
            [self presentSheet:AwardSheetTypeCancel];
        }
        else {
            [self presentSheet:AwardSheetTypeFailure];
        }
    }];
}

- (void)presentSheet:(AwardSheetType)type
{
    AwardOtherSheetVC * otherVC = [awardStoryboard instantiateViewControllerWithIdentifier:@"AwardOtherSheetVC"];
    otherVC.sheetType = type;
    MZFormSheetController *resultSheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(300, 200) viewController:otherVC];
    resultSheet.shouldCenterVertically = YES;
    [resultSheet presentAnimated:YES completionHandler:nil];
    
    [[otherVC.carwashBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [resultSheet dismissAnimated:YES completionHandler:nil];
        CarWashTableVC *vc = [UIStoryboard vcWithId:@"CarWashTableVC" inStoryboard:@"Carwash"];
        vc.type = 1;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    [[otherVC.closeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [resultSheet dismissAnimated:YES completionHandler:nil];
    }];
}

@end
