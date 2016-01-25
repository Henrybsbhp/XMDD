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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wechatBtnlLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLineBtnLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weiboBtnLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qqBtnLeading;

@property (nonatomic, strong) NSMutableArray * btnConstraintArr;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

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
    
    self.activityIndicatorView.hidden = YES;
    
    self.btnConstraintArr = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.btnTypeArr.count; i++) {
        ShareButtonType btnType = [self.btnTypeArr[i] intValue];
        if (btnType == ShareButtonWechat) {
            
            [self.btnConstraintArr addObject:self.wechatBtnlLeading];
            self.wechatBtn.hidden = NO;
            self.wechatLabel.hidden = NO;
            if ([WXApi isWXAppInstalled]) {
                self.wechatBtn.enabled = YES;
                self.wechatLabel.textColor = [UIColor colorWithHex:@"#545454" alpha:1.0f];
                
            }
        }
        if (btnType == ShareButtonTimeLine) {
            
            [self.btnConstraintArr addObject:self.timeLineBtnLeading];
            self.timelineBtn.hidden = NO;
            self.timeLineLabel.hidden = NO;
            if ([WXApi isWXAppInstalled]) {
                self.timelineBtn.enabled = YES;
                self.timeLineLabel.textColor = [UIColor colorWithHex:@"#545454" alpha:1.0f];
            }
        }
        if (btnType == ShareButtonWeibo) {
            
            [self.btnConstraintArr addObject:self.weiboBtnLeading];
            self.weiboBtn.hidden = NO;
            self.weiboLabel.hidden = NO;
            if (WeiboSDK.isWeiboAppInstalled) {
                self.weiboBtn.enabled = YES;
                self.weiboLabel.textColor = [UIColor colorWithHex:@"#545454" alpha:1.0f];
            }
        }
        if (btnType == ShareButtonQQFriend) {
            
            [self.btnConstraintArr addObject:self.qqBtnLeading];
            self.qqBtn.hidden = NO;
            self.qqLabel.hidden = NO;
            self.qqLabel.textColor = [UIColor colorWithHex:@"#545454" alpha:1.0f];
        }
    }
    
    [self autoArrangeWithConstraints:self.btnConstraintArr width:37];
    
    [super updateViewConstraints];
    
    [[_wechatBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"rp110-3"];
        
        if ([self catchLocalShareScene]) {
            [self shareWechat];
        }
        else {
            [self requestDetailsForButtonId:ShareButtonWechat];
        }
    }];
    
    [[_timelineBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"rp110-4"];
        
        if ([self catchLocalShareScene]) {
            [self shareTimeline];
        }
        else {
            [self requestDetailsForButtonId:ShareButtonTimeLine];
        }
    }];
    
    [[_weiboBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"rp110-5"];
        
        if ([self catchLocalShareScene]) {
            [self shareWeibo];
        }
        else {
            [self requestDetailsForButtonId:ShareButtonWeibo];
        }
    }];
    
    [[_qqBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"rp110-6"];
        
        if ([self catchLocalShareScene]) {
            [self shareQQ];
        }
        else {
            [self requestDetailsForButtonId:ShareButtonQQFriend];
        }
    }];
}

#pragma - ConstraintsTool
- (void)autoArrangeWithConstraints:(NSArray *)constraintArray width:(CGFloat)width
{
    CGFloat spacing = (290 - (width * constraintArray.count)) / (constraintArray.count + 1);
    for (int i = 0; i < constraintArray.count; i ++) {
        NSLayoutConstraint * constaint = constraintArray[i];
        constaint.constant = spacing * (i + 1) + width * i;
    }
}

- (BOOL)catchLocalShareScene
{
    if (self.sceneType == ShareSceneLocalShare || self.sceneType == ShareSceneCoupon) {
        if (self.clickAction) {
            CKAfter(0.3, ^{
                self.clickAction();
            });
        }
        return YES;
    }
    return NO;
}

- (void)requestDetailsForButtonId:(ShareButtonType)btnType
{
    self.activityIndicatorView.hidden = NO;
    [self.activityIndicatorView startAnimating];
    GetShareDetailOp * op = [GetShareDetailOp operation];
    op.pagePosition = self.sceneType;
    op.buttonId = btnType;
    if (self.sceneType == ShareSceneGas) {
        op.gasCharge = [self.otherInfo integerParamForName:@"gasCharge"];
        op.spareCharge = [self.otherInfo integerParamForName:@"spareCharge"];
    }
    else if (self.sceneType == ShareSceneValuation) {
        op.shareCode = [self.otherInfo stringParamForName:@"shareCode"];
    }
    @weakify(self);
    [[op rac_postRequest] subscribeNext:^(GetShareDetailOp * op) {
        
        @strongify(self);
        self.tt = op.rsp_title;
        self.subtitle = op.rsp_desc;
        self.urlStr = op.rsp_linkurl;
        [[gMediaMgr rac_getImageByUrl:op.rsp_imgurl withType:ImageURLTypeMedium defaultPic:@"wechat_share_carwash" errorPic:@"wechat_share_carwash"] subscribeNext:^(UIImage * x) {
            self.image = x;
        } completed:^{
            [self.activityIndicatorView stopAnimating];
            self.activityIndicatorView.hidden = YES;
            
            if (self.clickAction) {
                CKAfter(0.3, ^{
                    self.clickAction();
                });
            }
            if (btnType == ShareButtonWechat) {
                [self shareWechat];
            }
            else if (btnType == ShareButtonTimeLine) {
                [self shareTimeline];
            }
            else if (btnType == ShareButtonWeibo) {
                [self shareWeibo];
            }
            else if (btnType == ShareButtonQQFriend) {
                [self shareQQ];
            }
        }];
    } error:^(NSError *error) {
        [self.activityIndicatorView stopAnimating];
        self.activityIndicatorView.hidden = YES;
        [gToast showError:error.domain];
        if (self.clickAction) {
            CKAfter(0.3, ^{
                self.clickAction();
            });
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
//            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"分享失败" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
//            [msgbox show];
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
//            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未安装手机QQ" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
//            [msgbox show];
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            break;
        }
        case EQQAPISENDFAILD:
        {
//            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"错误" message:@"分享失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
//            [msgbox show];
            break;
        }
        default:
        {
            break;
        }
    }
}

@end
