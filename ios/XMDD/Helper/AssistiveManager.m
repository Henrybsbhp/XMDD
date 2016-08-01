//
//  AssistiveManager.m
//  XiaoMa
//
//  Created by fuqi on 16/7/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "AssistiveManager.h"
#import "JTLogModel.h"
#import "NetworkInterfaceTableVC.h"
#import "UIView+HKLine.h"

#ifdef DEBUG
#import "RRFPSBar.h"
#endif



@interface AssistiveManager ()

/// 日志
@property (nonatomic,strong)JTLogModel * logModel;

@property (nonatomic, strong)CKList *logDatasource;


@end

@implementation AssistiveManager

+ (AssistiveManager *)sharedManager
{
    static dispatch_once_t onceToken;
    static AssistiveManager *g_assistiveManager;
    dispatch_once(&onceToken, ^{
        g_assistiveManager = [[AssistiveManager alloc] init];
    });
    return g_assistiveManager;
}

#pragma mark - Setup
- (void)setupFPSObserver
{
#ifdef DEBUG
    [[RRFPSBar sharedInstance] setShowsAverage:YES];
    [[RRFPSBar sharedInstance] setHidden:YES];
#endif
}


#pragma mark - Action
- (void)uploadLog
{
    if (!self.logModel)
    {
        self.logModel = [[JTLogModel alloc] init];
    }
    else
    {
        if (self.logModel.islogViewAppear)
        {
            return;
        }
    }
    self.logModel.userid = gAppMgr.myUser.userID ? gAppMgr.myUser.userID : @"00000000000";
    self.logModel.appname = @"com.huika.xmdd";
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.logModel addToScreen];
    });
}

- (void)switchShowLogWithAlertView
{
    self.isShowRequestParamsAlert = !self.isShowRequestParamsAlert;
}

- (void)showLogWithAlertView:(NSDictionary *)params andMethodName:(NSString *)method
                     andOpId:(NSInteger)opid andDescription:(NSString *)desc
{
    if (self.isShowRequestParamsAlert)
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                           options:0
                                                             error:nil];
        NSString *string = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
        NSString *string2 = [[[string stringByReplacingOccurrencesOfString:@"," withString:@"\n"]
                              stringByReplacingOccurrencesOfString:@"{" withString:@""]
                             stringByReplacingOccurrencesOfString:@"}" withString:@""];
        NSString *requestParamsString = [NSString stringWithFormat:@"%@\ndata = %@ \n", method, string2];
        
        NSString *title = [NSString stringWithFormat:@"Request [%@] %ld",desc,(long)opid];
        UIAlertView *requestParamsAlertView = [[UIAlertView alloc] initWithTitle:title message:requestParamsString delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil, nil];
        [requestParamsAlertView show];
    }
}

- (void)showFPSObserver
{
#ifdef DEBUG
    [[RRFPSBar sharedInstance] setHidden:![RRFPSBar sharedInstance].hidden];
#endif
}



- (void)switchShowLogWithTableVC
{
    if (self.isRecordLog)
    {
        self.isRecordLog = NO;
        if (self.logDatasource.count)
        {
            NetworkInterfaceTableVC * vc = [UIStoryboard vcWithId:@"NetworkInterfaceTableVC" inStoryboard:@"Assistive"];
            vc.datasource = self.logDatasource;
            [gAppMgr.navModel.curNavCtrl pushViewController:vc animated:YES];
        }
        else
        {
            [gToast showText:@"录制期间无报文收发"];
        }
    }
    else
    {
        self.isRecordLog =  YES;
        self.logDatasource = nil;
    }
}

- (void)appendLogWithParams:(NSDictionary *)params andMethodName:(NSString *)method
                    andOpId:(NSInteger)opid andDescription:(NSString *)desc
{
    if (!self.isRecordLog)
    {
        return;
    }
    if (!self.logDatasource)
    {
        self.logDatasource = [CKList list];
    }
    
    CKList * list = [CKList list];
    
    CKDict * cell0 = [CKDict dictWith:@{kCKCellID:@"titleCell"}];
    cell0[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 30;
    });
    cell0[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UILabel * lb = [cell.contentView viewWithTag:101];
        NSString * name = [NSString stringWithFormat:@"❗️%@",desc];
        lb.text = name;
    });

    
    CKDict * cell1 = [CKDict dictWith:@{kCKCellID:@"titleCell"}];
    cell1[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 30;
    });
    cell1[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UILabel * lb = [cell.contentView viewWithTag:101];
        NSString * methodName = [NSString stringWithFormat:@"‼️%@",method];
        lb.text = methodName;
        
        [cell drawLineWithDirection:CKViewBorderDirectionBottom withEdge:UIEdgeInsetsMake(0, 12, 0, 12)];
    });
    
    [list addObject:cell0 forKey:nil];
    [list addObject:cell1 forKey:nil];
    
    for (NSString * key in [params allKeys])
    {
        NSString * value = [params objectForKey:key];
        CKDict * cell = [CKDict dictWith:@{kCKCellID:@"valueCell"}];
        cell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
            
            return 25;
        });
        cell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
            
            UILabel * lb1 = [cell.contentView viewWithTag:101];
            lb1.text = key;
            
            UILabel * lb2 = [cell.contentView viewWithTag:103];
            lb2.text = [NSString stringWithFormat:@"%@",value];
        });
        
        [list addObject:cell forKey:nil];
    }
    
    [self.logDatasource addObject:list forKey:nil];
}

@end
