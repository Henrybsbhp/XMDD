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

@implementation PasteboardModel

- (BOOL)checkPasteboard
{
    [[RACObserve(gAppMgr, myUser) distinctUntilChanged] subscribeNext:^(JTUser * user) {
       
        NSString * pasteboardStr = [UIPasteboard generalPasteboard].string;
        if ([pasteboardStr hasPrefix:XMINSPrefix])
        {
            if (user)
            {
                [self handleXMInsTag:pasteboardStr];
            }
            else
            {
                [self handleNoLogin];
            }
        }
    }];
    
    return YES;
}

- (void)handleNoLogin
{
    InviteAlertVC * alertVC = [[InviteAlertVC alloc] init];
    alertVC.alertType = InviteAlertTypeNologin;
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:HEXCOLOR(@"#888888") clickBlock:self.cancelClickBlock];
    HKAlertActionItem *login = [HKAlertActionItem itemWithTitle:@"去登录" color:HEXCOLOR(@"#18d06a") clickBlock:nil];
    alertVC.actionItems = @[cancel, login];
    [alertVC showWithActionHandler:^(NSInteger index, HKAlertVC *alertView) {
        [alertView dismiss];
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
    SearchCooperationGroupOp * op = [SearchCooperationGroupOp operation];
    op.req_cipher = str;
    [[op rac_postRequest] subscribeNext:^(SearchCooperationGroupOp * rop) {
        
        InviteAlertVC * alertVC = [[InviteAlertVC alloc] init];
        alertVC.alertType = InviteAlertTypeJoin;
        alertVC.groupName = rop.rsp_name;
        alertVC.leaderName = rop.rsp_creatorname;
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:HEXCOLOR(@"#888888") clickBlock:self.cancelClickBlock];
        HKAlertActionItem *join = [HKAlertActionItem itemWithTitle:@"确定加入" color:HEXCOLOR(@"#18d06a") clickBlock:nil];
        alertVC.actionItems = @[cancel, join];
        [alertVC showWithActionHandler:^(NSInteger index, HKAlertVC *alertView) {
            
            [UIPasteboard generalPasteboard].string = @"";
            [alertView dismiss];
            if (index == 1) {
                
                MutualInsGroupInfoVC * vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutualInsGroupInfoVC"];
                vc.groupId = rop.rsp_groupid;
                vc.groupCreateName = rop.rsp_creatorname;
                vc.groupName = rop.rsp_name;
                vc.cipher = rop.rsp_cipher;
                [gAppMgr.navModel.curNavCtrl pushViewController:vc animated:YES];
            }
        }];
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];

}

@end
