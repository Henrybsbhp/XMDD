//
//  AboutViewController.m
//  XiaoMa
//
//  Created by jt on 15-5-12.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "AboutViewController.h"
#import "JTTableView.h"
#import "FeedbackVC.h"
#import "SocialShareViewController.h"
#import "JoinUsViewController.h"
#import "GetShareButtonOpV2.h"
#import "ShareResponeManager.h"
#import "ReactTestViewController.h"
#import "ReactNativeDeveloperVC.h"
#import "RRFPSBar.h"
#import "ScanQRCodeVC.h"

typedef void(^MyBlock)(void);

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionLb;
@property (weak, nonatomic) IBOutlet JTTableView *tableView;

- (IBAction)joinAction:(id)sender;

@end

@implementation AboutViewController

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"AboutViewController dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    

    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    
#ifndef DEBUG
    #if XMDDENT == 0
    version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    #endif
#endif
    
    self.versionLb.text = version;
    
    [self setupDatasource];
    [self.tableView reloadData];
}

- (void)setupDatasource
{
    @weakify(self)
    CKDict * wechat = [self setupCellWithTitle:@"微信公众号" andAction:^{
       
        @strongify(self)
        [self gotoWechatWebVC];
    }];
    
    CKDict * helper = [self setupCellWithTitle:@"使用帮助" andAction:^{
       
        @strongify(self)
        [self gotoInstructions];
    }];
    
    CKDict * share = [self setupCellWithTitle:@"推荐App给好友" andAction:^{
       
        @strongify(self)
        [self shareApp];
    }];
    
    CKDict * service = [self setupCellWithTitle:@"用户服务协议" andAction:^{
       
        @strongify(self)
        [self serviceAgreement];
    }];
    
    CKDict * rate = [self setupCellWithTitle:@"前往评价" andAction:^{
        
        @strongify(self)
        [self rateOurApp];
    }];
    
    CKDict * feedback = [self setupCellWithTitle:@"意见反馈" andAction:^{
        
        @strongify(self)
        [self gotoFeedback];
    }];
    
    CKDict * callService = [self setupCellWithTitle:@"客服电话4007-111-111" andAction:^{
        
        @strongify(self)
        [self callCustomerService];
    }];
    
    CKDict * testWeb = [self setupCellWithTitle:@"网页跳转" andAction:^{
        
        @strongify(self)
        [self gotoTestWeb];
    }];
    
    CKDict * fps = [self setupCellWithTitle:@"FPS开关" andAction:^{
        
        @strongify(self)
        [self setupFPSObserver];
    }];
    
    CKDict * rct1 = [self setupCellWithTitle:@"React Native" andAction:^{
        
        @strongify(self)
        [self actionRCT];
    }];
    

    CKDict * paramsAlert = [self setupCellWithTitle:@"网络请求参数开关" andAction:^{
       
        @strongify(self)
        [self actionShowRequestParamsAlert];
    }];
    
    CKDict * qr = [self setupCellWithTitle:@"二维码扫描" andAction:^{
        
        @strongify(self)
        [self goToQRScanVC];
    }];
    
    CKList * list = [CKList list];
    [list addObject:wechat forKey:nil];
    [list addObject:helper forKey:nil];
    if (gAppMgr.canShareFlag)
    {
    [list addObject:share forKey:nil];
    }
    [list addObject:service forKey:nil];
    [list addObject:rate forKey:nil];
    [list addObject:feedback forKey:nil];
    [list addObject:callService forKey:nil];
    
#ifdef DEBUG
    [list addObject:testWeb forKey:nil];
    [list addObject:fps forKey:nil];
    [list addObject:rct1 forKey:nil];
    [list addObject:paramsAlert forKey:nil];
    [list addObject:qr forKey:nil];
#endif
    
    self.datasource = $(list);
}

- (CKDict *)setupCellWithTitle:(NSString *)title andAction:(MyBlock)actionAction
{
    CKDict *cell = [CKDict dictWith:@{kCKItemKey: @"AboutCell", kCKCellID: @"AboutCell"}];
    cell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 45;
    });
    
    cell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        if (actionAction)
        {
            actionAction();
        }
    });
    cell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UILabel * lb = (UILabel *)[cell searchViewWithTag:101];
        lb.text = title;
    });
    
    return cell;
}



#pragma mark - Utilitly
- (void)gotoWechatWebVC
{
    [MobClick event:@"wodeguanyu" attributes:@{@"guanyu" : @"wexingongzhonghao"}];
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.title = @"微信公众号";
    vc.url = kWechatPublicAccountUrl;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)rateOurApp
{
    [MobClick event:@"wodeguanyu" attributes:@{@"guanyu" : @"qianwangpingjia"}];
    NSString *url = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/xiao-ma-da-da-xi-che-zhi-yao1fen/id991665445&mt=8"];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:url]];
}

- (void)serviceAgreement
{
    [MobClick event:@"wodeguanyu" attributes:@{@"guanyu" : @"yonghuxieyi"}];
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.title = @"服务协议";
    vc.url = kServiceLicenseUrl;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoInstructions
{
    [MobClick event:@"wodeguanyu" attributes:@{@"guanyu" : @"shiyongbangzhu"}];
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.title = @"使用帮助";
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    vc.url = [NSString stringWithFormat:@"%@%@.html",kAboutViewServiceHelpUrl,version];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) shareApp
{
    [MobClick event:@"wodeguanyu" attributes:@{@"guanyu" : @"fenxiang"}];
    [gToast showingWithText:@"分享信息拉取中..."];
    GetShareButtonOpV2 * op = [GetShareButtonOpV2 operation];
    op.pagePosition = ShareSceneInsurance;
    [[op rac_postRequest] subscribeNext:^(GetShareButtonOpV2 * op) {
        
        [gToast dismiss];
        SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
        vc.sceneType = ShareSceneAppAbout;    //页面位置
        vc.btnTypeArr = op.rsp_shareBtns; //分享渠道数组
        vc.mobBaseValue = @"wodeguanyu";
        
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
        sheet.shouldCenterVertically = YES;
        [sheet presentAnimated:YES completionHandler:nil];
        [MobClick event:@"fenxiangyemian" attributes:@{@"chuxian":@"wodeguanyu"}];
        
        [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            [MobClick event:@"fenxiangyemian" attributes:@{@"quxiao":@"wodeguanyu"}];
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        [vc setClickAction:^{
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        
    } error:^(NSError *error) {
        [gToast showError:@"分享信息拉取失败，请重试"];
    }];
}

- (void)callCustomerService
{
    [MobClick event:@"wodeguanyu" attributes:@{@"guanyu" : @"kefu"}];
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
        [gPhoneHelper makePhone:@"4007111111"];
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"投诉建议,商户加盟等\n请拨打客服电话: 4007-111-111" ActionItems:@[cancel,confirm]];
    [alert show];
}

- (void)gotoFeedback
{
    [MobClick event:@"wodeguanyu" attributes:@{@"guanyu" : @"yijianfankui"}];
    FeedbackVC *vc = [UIStoryboard vcWithId:@"FeedbackVC" inStoryboard:@"About"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoTestWeb
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"请输入网址" message:@"" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"前往",nil];
    [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *textField = [av textFieldAtIndex:0];
    textField.text = @"https://";
    [av show];
    
    @weakify(self);
    [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber *n) {
        @strongify(self)
        NSInteger i = [n integerValue];
        if (i == 1)
        {
            DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
            vc.url = textField.text;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }];
}

- (void)goToQRScanVC
{
    ScanQRCodeVC *vc = [[ScanQRCodeVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)switchSurrounding
{
    gAppMgr.isSwitchToFormalSurrounding = !gAppMgr.isSwitchToFormalSurrounding;
}

- (IBAction)joinAction:(id)sender {
    /**
     *  商户加盟点击事件
     */
    [MobClick event:@"wodeguanyu" attributes:@{@"navi" : @"shanghujiameng"}];
    JoinUsViewController * vc = [UIStoryboard vcWithId:@"JoinUsViewController" inStoryboard:@"About"];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)actionBack:(id)sender
{
    [super actionBack:sender];
    [MobClick event:@"wodeguanyu" attributes:@{@"navi" : @"back"}];
}


#pragma mark - FPS
- (void)setupFPSObserver
{
    [gAssistiveMgr showFPSObserver];
}

#pragma mark - RN
- (void)actionRCT
{
    ReactNativeDeveloperVC *vc = [[ReactNativeDeveloperVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Network request parameters
- (void)actionShowRequestParamsAlert {
    [gAssistiveMgr switchShowLogWithAlertView];
}

@end
