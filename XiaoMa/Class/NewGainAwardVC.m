//
//  NewGainAwardVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/1/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "NewGainAwardVC.h"
#import "HYScratchCardView.h"
#import "CheckUserAwardOp.h"
#import "GainUserAwardOp.h"
#import "GetShareButtonOp.h"
#import "GetShareDetailOp.h"
#import "SocialShareViewController.h"
#import "ShareResponeManager.h"
#import "SharedNotifyOp.h"
#import "AwardShareSheetVC.h"
#import "AwardOtherSheetVC.h"
#import "CarWashTableVC.h"
#import "DetailWebVC.h"

@interface NewGainAwardVC ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;
@property (weak, nonatomic) IBOutlet UIView *scratchView;
@property (weak, nonatomic) IBOutlet UILabel *rmbLabel;
@property (weak, nonatomic) IBOutlet UILabel *amount;
@property (weak, nonatomic) IBOutlet UILabel *amountTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *carwashFlagView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *carwashBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *instructionBtn;

@property (strong, nonatomic) HYScratchCardView * hyscratchView;
@property (assign, nonatomic) BOOL isScratched;
@property (assign, nonatomic) BOOL otherActionFlag;

@end

@implementation NewGainAwardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self requestOperation];
}

-(void)viewWillAppear:(BOOL)animated
{
    [MobClick beginLogPageView:@"rp402"];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.otherActionFlag = YES;
    
    [MobClick endLogPageView:@"rp402"];
    [super viewWillDisappear:animated];
}

- (void)requestOperation
{
    self.coverView.hidden = NO;
    self.view.indicatorPoistionY = floor((self.view.frame.size.height - 75)/2.0);
    [self.coverView hideDefaultEmptyView];
    [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    @weakify(self);
    CheckUserAwardOp * op = [CheckUserAwardOp operation];
    [[op rac_postRequest] subscribeNext:^(CheckUserAwardOp * op) {
        
        @strongify(self);
        self.coverView.hidden = YES;
        [self.view stopActivityAnimation];
        //从未洗过车或活动日没洗过车
        if (!op.rsp_carwashflag) {
            [self.carwashBtn setTitle:@"0元洗车" forState:UIControlStateNormal];
            self.instructionBtn.hidden = NO;
            [[self.instructionBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
                
                @strongify(self);
                
                DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
                vc.url = @"http://www.xiaomadada.com/apphtml/lingyuanxiche.html";
                [self.navigationController pushViewController:vc animated:YES];
            }];
        }
        
        if (op.rsp_leftday > 0) {
            self.amount.text = [NSString stringWithFormat:@"%ld", (long)op.rsp_amount];
            if ([UIScreen mainScreen].bounds.size.height == 480) {
                self.amount.font = [UIFont systemFontOfSize:42];
            }
            self.tipLabel.text = [NSString stringWithFormat:@"您已领取礼券，%ld天后再来领取吧！", (long)op.rsp_leftday];
            if (op.rsp_isused) {
                self.carwashFlagView.hidden = NO;
                self.rmbLabel.textColor = [UIColor lightGrayColor];
                self.amount.textColor = [UIColor lightGrayColor];
                self.amountTypeLabel.textColor = [UIColor lightGrayColor];
            }
            [[self.carwashBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
                
                @strongify(self);
                CarWashTableVC *vc = [UIStoryboard vcWithId:@"CarWashTableVC" inStoryboard:@"Carwash"];
                [self.navigationController pushViewController:vc animated:YES];
            }];
            [[self.shareBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
                
                @strongify(self);
                [self shareAction];
            }];
        }
        else {
            self.isScratched = NO;
            [self setupScratchView];
            self.tipLabel.text = [NSString stringWithFormat:@"已有%ld人领取", (long)op.rsp_total];
            [[self.carwashBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
                
                [MobClick event:@"rp402-6"];
                @strongify(self);
                if (!self.isScratched) {
                    [gToast showText:@"请先刮卡领取礼券"];
                }
                else {
                    CarWashTableVC *vc = [UIStoryboard vcWithId:@"CarWashTableVC" inStoryboard:@"Carwash"];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }];
            [[self.shareBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
                
                [MobClick event:@"rp402-2"];
                @strongify(self);
                if (!self.isScratched) {
                    [gToast showText:@"请先刮卡领取礼券"];
                }
                else {
                    self.otherActionFlag = YES;
                    [self shareAction];
                }
            }];
        }
    } error:^(NSError *error) {
        
        @strongify(self);
        [self.view stopActivityAnimation];
        [self.coverView showDefaultEmptyViewWithText:@"获取礼券信息失败，请点击重试" tapBlock:^{
            [self requestOperation];
        }];
    }];
}

- (void)setupScratchView
{
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        self.amount.font = [UIFont systemFontOfSize:42];
    }
    @weakify(self);
    CKAsyncMainQueue(^{
        @strongify(self);
        self.hyscratchView = [[HYScratchCardView alloc]initWithFrame:CGRectMake(0, 0, self.scratchView.frame.size.width, self.scratchView.frame.size.height)];
        self.hyscratchView.image = [UIImage imageNamed:@"award_mask"];
        
        self.hyscratchView.completion = ^(id userInfo) {
            @strongify(self);
            [MobClick event:@"rp402-7"];
            [self gainAward];
        };
        [self.scratchView addSubview:self.hyscratchView];
    });
}

- (void)gainAward
{
    GainUserAwardOp * op = [GainUserAwardOp operation];
    op.req_province = gMapHelper.addrComponent.province;
    op.req_city = gMapHelper.addrComponent.city;
    op.req_district = gMapHelper.addrComponent.district;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"抢礼券中..."];
    }] subscribeNext:^(GainUserAwardOp * op) {
        
        @strongify(self);
        [gToast dismiss];
        
        self.isScratched = YES;
        self.amount.text = [NSString stringWithFormat:@"%ld", (long)op.rsp_amount];
        self.tipLabel.text = op.rsp_tip;
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.hyscratchView.alpha = 0;
                         }];
        
        CKAfter(1.5, ^{
            @strongify(self);
            //若弹出分享窗之前用户进行了其他操作，则不弹出
            if (!self.otherActionFlag) {
                [self showShareSheet];
            }
        });
        
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

- (void)showShareSheet
{
    AwardShareSheetVC * sheetVC = [awardStoryboard instantiateViewControllerWithIdentifier:@"AwardShareSheetVC"];
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(285, 365) viewController:sheetVC];
    sheet.shouldCenterVertically = YES;
    [sheet presentAnimated:YES completionHandler:nil];
    
    [[sheetVC.shareBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @weakify(self);
        [sheet dismissAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
            @strongify(self);
            [self shareAction];
        }];
    }];
    
    [[sheetVC.closeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [sheet dismissAnimated:YES completionHandler:nil];
    }];
}

- (void)shareAction
{
    [gToast showingWithText:@"分享信息拉取中..."];
    GetShareButtonOp * op = [GetShareButtonOp operation];
    op.pagePosition = ShareSceneGain;
    @weakify(self);
    [[op rac_postRequest] subscribeNext:^(GetShareButtonOp * op) {
        
        [gToast dismiss];
        SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
        vc.sceneType = ShareSceneGain;    //页面位置
        vc.btnTypeArr = op.rsp_shareBtns; //分享渠道数组
        
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
        sheet.shouldCenterVertically = YES;
        [sheet presentAnimated:YES completionHandler:nil];
        
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
        [gToast showError:@"分享信息拉取失败，请重试"];
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
    MZFormSheetController *resultSheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(285, 260) viewController:otherVC];
    resultSheet.shouldCenterVertically = YES;
    [resultSheet presentAnimated:YES completionHandler:nil];
    
    @weakify(self);
    [[otherVC.carwashBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        /**
         *  去洗车点击事件
         */
        [MobClick event:@"rp402-3"];
        @strongify(self);
        [resultSheet dismissAnimated:YES completionHandler:nil];
        CarWashTableVC *vc = [UIStoryboard vcWithId:@"CarWashTableVC" inStoryboard:@"Carwash"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    [[otherVC.closeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        /**
         *  取消按钮点击事件
         */
        if(otherVC.sheetType == AwardSheetTypeSuccess)
        {
            [MobClick event:@"rp402-4"];
            
        }
        else if(otherVC.sheetType == AwardSheetTypeCancel)
        {
            [MobClick event:@"rp402-5"];
        }
        [resultSheet dismissAnimated:YES completionHandler:nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
    DebugLog(@"NewGainAwardVC dealloc");
}

@end
