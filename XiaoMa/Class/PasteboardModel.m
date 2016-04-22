//
//  PasteboardModel.m
//  XiaoMa
//
//  Created by jt on 16/3/21.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "PasteboardModel.h"
#import "InviteAlertVC.h"
#import "SearchCooperationGroupOp.h"
#import "MutualInsGroupInfoVC.h"
#import "HKImageAlertVC.h"
#import "GroupIntroductionVC.h"

@interface PasteboardModel ()

@property (nonatomic, assign) BOOL isAlertShowing;

@end

@implementation PasteboardModel

- (void)prepareForShareWhisper:(NSString *)whisper
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = whisper;
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    [def setObject:whisper forKey:@"Mutaul_InviteCodeForShare"];
}

- (BOOL)checkPasteboard
{
    [[RACObserve(gAppMgr, myUser) distinctUntilChanged] subscribeNext:^(JTUser * user) {
       
        NSString * pasteboardStr = [UIPasteboard generalPasteboard].string;
        NSString * defStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"Mutaul_InviteCodeForShare"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Mutaul_InviteCodeForShare"];
        if ([pasteboardStr isEqualToString:defStr]) {
            [UIPasteboard generalPasteboard].string = @"";
        }
        else if ([pasteboardStr hasPrefix:XMINSPrefix])
        {
            if (user)
            {
                [self handleXMInsTag:pasteboardStr];
            }
            else if (!self.isAlertShowing)
            {
                [self handleNoLogin];
            }
        }
    }];
    
    return YES;
}

- (void)handleNoLogin
{
    self.isAlertShowing = YES;
    InviteAlertVC * alertVC = [[InviteAlertVC alloc] init];
    alertVC.alertType = InviteAlertTypeNologin;
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:self.cancelClickBlock];
    HKAlertActionItem *login = [HKAlertActionItem itemWithTitle:@"去登录" color:kDefTintColor clickBlock:self.nextClickBlock];
    alertVC.actionItems = @[cancel, login];
    [alertVC showWithActionHandler:^(NSInteger index, HKAlertVC *alertView) {
        [alertView dismiss];
        self.isAlertShowing = NO;
        if (index == 1) {
            [gAppMgr.navModel pushToViewControllerByUrl:@"xmdd://j?t=login"];
        }
        else {
            [UIPasteboard generalPasteboard].string = @"";
        }
    }];
}



- (void)handleXMInsTag:(NSString *)str
{
    [UIPasteboard generalPasteboard].string = @"";
    SearchCooperationGroupOp * op = [SearchCooperationGroupOp operation];
    op.req_cipher = str;
    [[op rac_postRequest] subscribeNext:^(SearchCooperationGroupOp * rop) {
        
        InviteAlertVC * alertVC = [[InviteAlertVC alloc] init];
        alertVC.alertType = InviteAlertTypeJoin;
        alertVC.groupName = rop.rsp_name;
        alertVC.groupType = rop.rsp_groupType;
        alertVC.leaderName = rop.rsp_creatorname;
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:self.cancelClickBlock];
        HKAlertActionItem *join = [HKAlertActionItem itemWithTitle:@"确定加入" color:kDefTintColor clickBlock:self.nextClickBlock];
        alertVC.actionItems = @[cancel, join];
        [alertVC showWithActionHandler:^(NSInteger index, HKAlertVC *alertView) {
            
            [alertView dismiss];
            if (index == 1) {
                if (rop.rsp_groupType == GroupTypeByself) {
                    MutualInsGroupInfoVC * vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutualInsGroupInfoVC"];
                    vc.groupId = rop.rsp_groupid;
                    vc.groupCreateName = rop.rsp_creatorname;
                    vc.groupName = rop.rsp_name;
                    vc.cipher = rop.rsp_cipher;
                    [gAppMgr.navModel.curNavCtrl pushViewController:vc animated:YES];
                }
                else {
                    GroupIntroductionVC * vc = [UIStoryboard vcWithId:@"GroupIntroductionVC" inStoryboard:@"MutualInsJoin"];
                    vc.titleStr = @"平台团介绍";
                    vc.groupType = MutualGroupTypeSystem;
                    vc.btnType = BtnTypeJoinNow;
                    vc.groupId = rop.rsp_groupid;
                    vc.groupName = rop.rsp_name;
                    [gAppMgr.navModel.curNavCtrl pushViewController:vc animated:YES];
                }
            }
        }];
    } error:^(NSError *error) {
        if (error.code == 6115702) {
            HKImageAlertVC *alert = [[HKImageAlertVC alloc] init];
            alert.topTitle = @"温馨提示";
            alert.imageName = @"mins_bulb";
            alert.message = error.domain;
            HKAlertActionItem *ok = [HKAlertActionItem itemWithTitle:@"确定" color:kGrayTextColor clickBlock:nil];
            alert.actionItems = @[ok];
            [alert show];
        }
        else {
            [gToast showError:error.domain];
        }
    }];

}

@end
