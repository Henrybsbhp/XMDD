//
//  MyWebViewBridge.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/10/22.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "MyWebViewBridge.h"
#import "SocialShareViewController.h"
#import "HKImagePicker.h"
#import "UploadFileOp.h"
#import "Reachability.h"

typedef NS_ENUM(NSInteger, MenuItemsType) {
    menuItemsTypeShare                  = 1,
    menuItemsTypeCollection             = 2
};

@implementation MyWebViewBridge

- (instancetype)initBridgeWithWebView:(WVJB_WEBVIEW_TYPE *)webView andDelegate:(WVJB_WEBVIEW_DELEGATE_TYPE *) delegate
{
    self = [super init];
    if (self)
    {
        self.myBridge = [WebViewJavascriptBridge bridgeForWebView:webView webViewDelegate:delegate handler:^(id data, WVJBResponseCallback responseCallback) {
            //注册bridge，并用于接收所有JS的send方法
            //        NSLog(@"ObjC received message from JS: %@", data);
            //        responseCallback(@"Response for message from ObjC");
        }];
    }
    return self;

}

#pragma mark - 传递用户token
- (void)registerGetToken
{
    [self.myBridge registerHandler:@"getUserToken" handler:^(id data, WVJBResponseCallback responseCallback) {
        id backData;
        if (gNetworkMgr.token && gAppMgr.myUser.userID) {
            backData = @{ @"token" : gNetworkMgr.token, @"phone" : gAppMgr.myUser.userID};
        }
        else {
            backData = nil;
        }
        NSString * dataStr = [backData jsonEncodedString];
        responseCallback(dataStr);
    }];
}

#pragma mark - 获取弱提示弹框内容
- (void)registerToastMsg
{
    [self.myBridge registerHandler:@"sendToastMsg" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString * toastMsg = [data stringParamForName:@"message"];
        if (toastMsg) {
            [gToast showText:[NSString stringWithFormat:@"%@", toastMsg]];
        }
        responseCallback(nil);
    }];
}

#pragma mark - 获取地理位置信息
- (void)registerSetPosition
{
    [self.myBridge registerHandler:@"getCurrentPosition" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString * longitudeStr = [NSString stringWithFormat:@"%f", gMapHelper.coordinate.longitude];
        NSString * latitudeStr = [NSString stringWithFormat:@"%f", gMapHelper.coordinate.latitude];
        NSString * province = gAppMgr.addrComponent.province;
        NSString * city = gAppMgr.addrComponent.city;
        NSString * district = gAppMgr.addrComponent.district;
        if (longitudeStr && longitudeStr && latitudeStr) {
            NSDictionary * dic = @{@"province":province, @"city":city, @"district":district, @"longitude":longitudeStr, @"latitude":latitudeStr};
            NSString * dicStr = [dic jsonEncodedString];
            responseCallback(dicStr);
        }
        else {
            responseCallback(nil);
        }
    }];
}

#pragma mark - 获取网络状态
- (void)registerNetworkState
{
    [self.myBridge registerHandler:@"callForNetworkState" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString * stateStr;
        Reachability *r=[Reachability reachabilityWithHostName:@"http://www.baidu.com"];
        switch ([r currentReachabilityStatus]) {
            case NotReachable:
                stateStr = @"0";
                break;
            case ReachableViaWWAN:{
                stateStr = @"1";
                break;
            case ReachableViaWiFi:
                stateStr = @"2";
                break;
            }
            default:
                break;
        }
        NSDictionary * dic = @{@"state":stateStr};
        NSString * dataStr = [dic jsonEncodedString];
        responseCallback(dataStr);
    }];
}

#pragma mark - 拨打电话
- (void)registerCallPhone
{
    [self.myBridge registerHandler:@"getPhoneCall" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString * phoneStr = [data stringParamForName:@"phoneNum"];
        [gPhoneHelper makePhone:phoneStr andInfo:[NSString stringWithFormat:@"拨打电话：%@", phoneStr]];
        
        responseCallback(nil);
    }];
}

#pragma mark - 上传图片
- (void)uploadImage:(UIViewController *)superVC
{
    NSMutableDictionary * imgDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * imguploadDic = [[NSMutableDictionary alloc] init];
    [self.myBridge registerHandler:@"selectSingleImage" handler:^(id data, WVJBResponseCallback responseCallback) {
        //存图片ID
        [imgDic addParam:[data stringParamForName:@"imgId"] forName:@"imgId"];
        [imguploadDic addParam:[data numberParamForName:@"type"] forName:@"type"];
        [imguploadDic addParam:[data numberParamForName:@"uploadUrl"] forName:@"uploadUrl"];
        HKImagePicker *picker = [HKImagePicker imagePicker];
        picker.allowsEditing = YES;
        picker.shouldShowBigImage = NO;
        @weakify(self);
        [[[picker rac_pickImageInTargetVC:superVC inView:superVC.navigationController.view] flattenMap:^RACStream *(UIImage *image) {
            
            NSData *data = UIImageJPEGRepresentation(image, 0.8f);
            NSString *encodedImageStr = [NSString stringWithFormat:@"data:image/jpeg;base64,%@", [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
            
            NSString * dataStr = [imgDic jsonEncodedString];//转json字符串
            [self.myBridge callHandler:@"singleImageBefore" data:dataStr responseCallback:^(id response) {
                
            }];
            
            //存编码
            [imgDic addParam:encodedImageStr forName:@"imageCodeStr"];
            
            UploadFileOp *op = [UploadFileOp new];
            op.req_fileType = [imguploadDic intParamForName:@"type"];
            op.req_fileExtType = @"jpg";
            op.req_uploadUrl = [imguploadDic stringParamForName:@"uploadUrl"];
            [op setFileArray:@[image] withGetDataBlock:^NSData *(UIImage *img) {
                return UIImageJPEGRepresentation(img, 1.0);
            }];
            return [op rac_postRequest];
        }] subscribeNext:^(UploadFileOp * rspOp) {
            @strongify(self);
            //存图片URL
            [imgDic addParam:rspOp.rsp_urlArray[0] forName:@"imageUrl"];
            
            NSString * dataStr = [imgDic jsonEncodedString];//转json字符串

            [self.myBridge callHandler:@"singleImageBack" data:dataStr responseCallback:^(id response) {
            }];
        } error:^(NSError *error) {
            //断网传空
            [imgDic addParam:@"" forName:@"imageUrl"];
            [imgDic addParam:@"" forName:@"imageCodeStr"];
            [self.myBridge callHandler:@"singleImageBack" data:imgDic responseCallback:^(id response) {
            }];
        }];
        
        responseCallback(nil);
    }];
}

#pragma mark - 点击查看大图
- (void)registerShowImage
{
    [self.myBridge registerHandler:@"callShowImage" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary * dic = data;
        NSString * imageUrl = [dic stringParamForName:@"imgUrl"];
        [self showImages:imageUrl];
        
        responseCallback(nil);
    }];
}

- (void)showImages:(NSString *)urlStr
{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIScrollView * backgroundView= [[UIScrollView alloc]
                                    initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    backgroundView.showsHorizontalScrollIndicator = NO;
    backgroundView.backgroundColor = [UIColor colorWithHex:@"#0000000" alpha:0.6f];
    backgroundView.alpha = 0;
    [backgroundView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    
    [[gMediaMgr rac_getImageByUrl:urlStr withType:ImageURLTypeOrigin defaultPic:@"cm_webimg_default" errorPic:@"cm_webimg_default"] subscribeNext:^(id x) {
        UIImage * img = x;
        CGRect frame = CGRectMake(0, ([UIScreen mainScreen].bounds.size.height-img.size.height*[UIScreen mainScreen].bounds.size.width/img.size.width)/2, [UIScreen mainScreen].bounds.size.width, img.size.height*[UIScreen mainScreen].bounds.size.width/img.size.width);
        imageView.frame = frame;
        [imageView setImage:img];
    } error:^(NSError *error) {
        [gToast showError:@"大图加载失败，请稍后重试"];
        [imageView setImage:[UIImage imageNamed:@"cm_webimg_default"]]; //默认错误大图
    }];
    
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer: tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView=tap.view;
    [UIView animateWithDuration:0.3 animations:^{
        backgroundView.alpha=0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
}

#pragma mark - 右上角菜单按钮（目前只有分享）
- (UIBarButtonItem *)setSingleMenu:(NSString *)singleBtn
{
    MenuItemsType type = [singleBtn integerValue];
    UIBarButtonItem *right;
    if (type == menuItemsTypeShare) {
        right = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(shareAction)];
    }
    else {
        //其他单个右上角功能按钮
    }
    [right setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:16.0]} forState:UIControlStateNormal];
    return right;
}

- (UIBarButtonItem *)setMultipleMenu:(NSArray *)btnArray
{
    UIBarButtonItem *right;
    for (NSString * btnStr in btnArray) {
        MenuItemsType type = [btnStr integerValue];
        if (type == menuItemsTypeShare) {
            right = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(shareAction)];
            [right setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:16.0]} forState:UIControlStateNormal];
        }
    }
    return right;
}

- (void)shareAction
{
    [MobClick event:@"rp203-1"];
    [self.myBridge callHandler:@"getShareParamHandler" data:nil responseCallback:^(id response) {
        NSDictionary *shareDic = response;
        SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
        vc.tt = [shareDic stringParamForName:@"title"];
        vc.subtitle = [shareDic stringParamForName:@"desc"];
        
        //可能可直接传url
        [[gMediaMgr rac_getImageByUrl:shareDic[@"imgUrl"] withType:ImageURLTypeMedium defaultPic:nil errorPic:nil] subscribeNext:^(id x) {
            vc.image = x;
        }];
        [[gMediaMgr rac_getImageByUrl:shareDic[@"imgUrlWb"] withType:ImageURLTypeMedium defaultPic:nil errorPic:nil] subscribeNext:^(id x) {
            vc.webimage = x;
        }];
        vc.urlStr = shareDic[@"linkUrl"];
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
        sheet.shouldCenterVertically = YES;
        [sheet presentAnimated:YES completionHandler:nil];
        
        [vc setFinishAction:^{
            
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        
        [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [MobClick event:@"rp110-7"];
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
    }];
}

@end
