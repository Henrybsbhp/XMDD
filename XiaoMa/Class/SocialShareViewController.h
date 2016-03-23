//
//  SocialShareViewController.h
//  XiaoMa
//
//  Created by jt on 15-5-20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WXApi.h"
#import "WXApiObject.h"

#import "WeiboSDK.h"

@interface SocialShareViewController : HKViewController

/// 点击分享按钮
@property (strong, nonatomic)void(^clickAction)(void);


@property (weak, nonatomic) IBOutlet UIButton *wechatBtn;
@property (weak, nonatomic) IBOutlet UIButton *timelineBtn;
@property (weak, nonatomic) IBOutlet UIButton *weiboBtn;
@property (weak, nonatomic) IBOutlet UIButton *qqBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@property (nonatomic)ShareSceneType sceneType;
@property (nonatomic, strong)NSMutableDictionary * otherInfo;
@property (nonatomic, strong)NSArray * btnTypeArr;

@property (nonatomic,copy)NSString * tt;
@property (nonatomic,copy)NSString * subtitle;
@property (nonatomic,copy)NSString * urlStr;
@property (nonatomic,strong)UIImage * image;
@property (nonatomic,strong)UIImage * webimage;

@property (nonatomic,strong)RACSubject * rac_dismissSignal;


@end
