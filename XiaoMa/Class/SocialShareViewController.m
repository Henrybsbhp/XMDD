//
//  SocialShareViewController.m
//  XiaoMa
//
//  Created by jt on 15-5-20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "SocialShareViewController.h"
#import <TencentOpenAPI.framework/Headers/QQApiInterface.h>
#import <TencentOpenAPI.framework/Headers/QQApiInterfaceObject.h>
#import "GetShareDetailOp.h"


@interface SocialShareViewController ()
@property (weak, nonatomic) IBOutlet UILabel *wechatLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLineLabel;
@property (weak, nonatomic) IBOutlet UILabel *weiboLabel;
@property (weak, nonatomic) IBOutlet UILabel *qqLabel;

@end

@implementation SocialShareViewController

- (instancetype)init
{
    self  = [super init];
    if (self)
    {
        _rac_dismissSignal = [RACSubject subject];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wechatBtn.enabled = NO;
    self.timelineBtn.enabled = NO;
    self.weiboBtn.enabled = NO;
    self.qqBtn.enabled = NO;
    
    for (int i = 0; i < self.btnTypeArr.count; i++) {
        ShareButtonType btnType = [self.btnTypeArr[i] intValue];
        if (btnType == ShareButtonWechat && [WXApi isWXAppInstalled]) {
            self.wechatBtn.enabled = YES;
            self.wechatLabel.textColor = [UIColor colorWithHex:@"#545454" alpha:1.0f];
        }
        if (btnType == ShareButtonTimeLine && [WXApi isWXAppInstalled]) {
            self.timelineBtn.enabled = YES;
            self.timeLineLabel.textColor = [UIColor colorWithHex:@"#545454" alpha:1.0f];
        }
        if (btnType == ShareButtonWeibo && WeiboSDK.isWeiboAppInstalled) {
            self.weiboBtn.enabled = YES;
            self.weiboLabel.textColor = [UIColor colorWithHex:@"#545454" alpha:1.0f];
        }
        if (btnType == ShareButtonQQFriend) {
            self.qqBtn.enabled = YES;
            self.qqLabel.textColor = [UIColor colorWithHex:@"#545454" alpha:1.0f];
        }
    }
    
    [[_wechatBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"rp110-3"];
        
        if (self.sceneType == ShareSceneAbout) {
            if (self.clickAction) {
                CKAfter(0.3, ^{
                    self.clickAction();
                });
            }
            [self shareWechat];
        }
        else {
            GetShareDetailOp * op = [GetShareDetailOp operation];
            op.pagePosition = self.sceneType;
            op.buttonId = ShareButtonWechat;
            @weakify(self);
            [[op rac_postRequest] subscribeNext:^(GetShareDetailOp * op) {
                
                @strongify(self);
                self.tt = op.rsp_title;
                self.subtitle = op.rsp_desc;
                self.urlStr = op.rsp_linkurl;
                [[gMediaMgr rac_getImageByUrl:op.rsp_imgurl withType:ImageURLTypeMedium defaultPic:@"wechat_share_carwash" errorPic:@"wechat_share_carwash"] subscribeNext:^(UIImage * x) {
                    self.image = x;
                    
                    if (self.clickAction) {
                        CKAfter(0.3, ^{
                            self.clickAction();
                        });
                    }
                    [self shareWechat];
                }];
            } error:^(NSError *error) {
                [gToast showError:error.domain];
                if (self.clickAction) {
                    CKAfter(0.3, ^{
                        self.clickAction();
                    });
                }
            }];
        }
    }];
    
    [[_timelineBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"rp110-4"];
        
        if (self.sceneType == ShareSceneAbout) {
            if (self.clickAction) {
                CKAfter(0.3, ^{
                    self.clickAction();
                });
            }
            [self shareTimeline];
        }
        else {
            GetShareDetailOp * op = [GetShareDetailOp operation];
            op.pagePosition = self.sceneType;
            op.buttonId = ShareButtonTimeLine;
            @weakify(self);
            [[op rac_postRequest] subscribeNext:^(GetShareDetailOp * op) {
                
                @strongify(self);
                self.tt = op.rsp_title;
                self.subtitle = op.rsp_desc;
                self.urlStr = op.rsp_linkurl;
                [[gMediaMgr rac_getImageByUrl:op.rsp_imgurl withType:ImageURLTypeMedium defaultPic:@"wechat_share_carwash" errorPic:@"wechat_share_carwash"] subscribeNext:^(UIImage * x) {
                    self.image = x;
                    
                    if (self.clickAction) {
                        CKAfter(0.3, ^{
                            self.clickAction();
                        });
                    }
                    [self shareTimeline];
                }];
            } error:^(NSError *error) {
                [gToast showError:error.domain];
                if (self.clickAction) {
                    CKAfter(0.3, ^{
                        self.clickAction();
                    });
                }
            }];
        }
    }];
    
    [[_weiboBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"rp110-5"];
        
        if (self.sceneType == ShareSceneAbout) {
            if (self.clickAction) {
                CKAfter(0.3, ^{
                    self.clickAction();
                });
            }
            [self shareWeibo];
        }
        else {
            GetShareDetailOp * op = [GetShareDetailOp operation];
            op.pagePosition = self.sceneType;
            op.buttonId = ShareButtonWeibo;
            @weakify(self);
            [[op rac_postRequest] subscribeNext:^(GetShareDetailOp * op) {
                
                @strongify(self);
                self.tt = op.rsp_title;
                self.subtitle = op.rsp_desc;
                self.urlStr = op.rsp_linkurl;
                [[gMediaMgr rac_getImageByUrl:op.rsp_imgurl withType:ImageURLTypeMedium defaultPic:@"award_element1" errorPic:@"award_element1"] subscribeNext:^(UIImage * x) {
                    self.webimage = x;
                    
                    if (self.clickAction) {
                        CKAfter(0.3, ^{
                            self.clickAction();
                        });
                    }
                    [self shareWeibo];
                }];
            } error:^(NSError *error) {
                [gToast showError:error.domain];
                if (self.clickAction) {
                    CKAfter(0.3, ^{
                        self.clickAction();
                    });
                }
            }];
        }
    }];
    
    [[_qqBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"rp110-6"];
        
        if (self.sceneType == ShareSceneAbout) {
            if (self.clickAction) {
                CKAfter(0.3, ^{
                    self.clickAction();
                });
            }
            [self shareQQ];
        }
        else {
            GetShareDetailOp * op = [GetShareDetailOp operation];
            op.pagePosition = self.sceneType;
            op.buttonId = ShareButtonQQFriend;
            @weakify(self);
            [[op rac_postRequest] subscribeNext:^(GetShareDetailOp * op) {
                
                @strongify(self);
                self.tt = op.rsp_title;
                self.subtitle = op.rsp_desc;
                self.urlStr = op.rsp_linkurl;
                [[gMediaMgr rac_getImageByUrl:op.rsp_imgurl withType:ImageURLTypeMedium defaultPic:@"award_element1" errorPic:@"award_element1"] subscribeNext:^(UIImage * x) {
                    self.image = x;
                    
                    if (self.clickAction) {
                        CKAfter(0.3, ^{
                            self.clickAction();
                        });
                    }
                    [self shareQQ];
                }];
            } error:^(NSError *error) {
                [gToast showError:error.domain];
                if (self.clickAction) {
                    CKAfter(0.3, ^{
                        self.clickAction();
                    });
                }
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DebugLog(@"SocialShareViewController dealloc ~~~");
}

- (void)shareWechat
{
    [self shareToWeChat:WXSceneSession withTitle:self.tt
             andDescription:self.subtitle andImage:self.image andUrl:self.urlStr];
}

- (void)shareTimeline
{
    [self shareToWeChat:WXSceneTimeline withTitle:self.tt
             andDescription:self.subtitle andImage:self.image andUrl:self.urlStr];
}

- (void)shareWeibo
{
    WBMessageObject *message = [WBMessageObject message];
    
    WBImageObject *image = [WBImageObject object];
    image.imageData = UIImagePNGRepresentation(self.webimage ? self.webimage : self.image);
    message.imageObject = image;
    message.text = [NSString stringWithFormat:@"%@ \n %@ \n %@ ",self.tt,self.subtitle,self.urlStr];
    
    WBSendMessageToWeiboRequest * request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    [WeiboSDK sendRequest:request];
}

- (void)shareQQ
{
    QQApiNewsObject *newsObj;
    newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:self.urlStr] title:self.tt description:self.subtitle previewImageData:UIImageJPEGRepresentation(self.image, 1.0)];

    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
}

- (void)shareToWeChat:(NSInteger)scene
            withTitle:(NSString *)title
       andDescription:(NSString *)desc
             andImage:(UIImage *)img
               andUrl:(NSString *)url
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = desc;
    [message setThumbImage:img];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.message = message;
    req.bText = NO;
    req.scene = (int)scene;
    
    [WXApi sendReq:req];
}

#pragma mark - QQ
- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手机QQ" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"分享失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        default:
        {
            break;
        }
    }
}

@end
