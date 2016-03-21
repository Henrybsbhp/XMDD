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
    alertVC.actionTitles = @[@"取消", @"去登录"];
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
        alertVC.actionTitles = @[@"取消", @"确定加入"];
        [alertVC showWithActionHandler:^(NSInteger index, HKAlertVC *alertView) {
            
//            [UIPasteboard generalPasteboard].string = @"";
            [alertView dismiss];
            if (index == 1) {
                [gAppMgr.navModel pushToViewControllerByUrl:@"xmdd://j?t=jg"];
            }
        }];
    } error:^(NSError *error) {
//        [gToast showError:@" 获取团信息失败 "];
    }];

}

@end
