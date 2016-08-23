//
//  DetailWebVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/10/21.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

#if XMDDEnvironment==0
@interface NSURLRequest (IgnoreSSL)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end
#elif XMDDEnvironment==1
@interface NSURLRequest (IgnoreSSL)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end
#else

#endif


@interface DetailWebVC : HKViewController

@property (nonatomic, weak) UIViewController *originVC;
@property (nonatomic, copy) NSString *url;

/// 有订单号的话，说明是从银联支付进入
@property (nonatomic, strong) NSString *tradeno;
/// 有信号的话，说明是从银联支付进入
@property (nonatomic, strong) RACSubject *subject;

/// 是否是从银联页面或者我的银行卡页面进入
@property (assign, nonatomic) BOOL fromUnionCardVC;


- (void)requestUrl:(NSString *)url;


@end
