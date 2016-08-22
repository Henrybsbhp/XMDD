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
@property (nonatomic, strong) NSString *tradeno;
@property (nonatomic, strong) RACSubject *subject;

- (void)requestUrl:(NSString *)url;


@end
