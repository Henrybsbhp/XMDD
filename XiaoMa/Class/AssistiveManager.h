//
//  AssistiveManager.h
//  XiaoMa
//
//  Created by fuqi on 16/7/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTouchButton.h"
#import "BaseOp.h"

@interface AssistiveManager : NSObject



/// 是否显示AssistiveView
@property (nonatomic)BOOL isShowAssistiveView;
/// 是否需要让网络请求参数信息显示为一个 Alert
@property (nonatomic)BOOL isShowRequestParamsAlert;
/// 是否录制日志
@property (nonatomic)BOOL isRecordLog;

+ (AssistiveManager *)sharedManager;

/// 设置FPS功能
- (void)setupFPSObserver;
///上传日志
- (void)uploadLog;

///显示实时日志开关
- (void)switchShowLogWithAlertView;
///显示实时日志
- (void)showLogWithAlertView:(NSDictionary *)params andMethodName:(NSString *)method
                     andOpId:(NSInteger)opid andDescription:(NSString *)desc;

///用表格形式展示日志开关
- (void)switchShowLogWithTableVC;
///用表格形式展示日志添加
- (void)appendLogWithParams:(NSDictionary *)params andMethodName:(NSString *)method
                    andOpId:(NSInteger)opid andDescription:(NSString *)desc;
///显示FPS
- (void)showFPSObserver;


@end
