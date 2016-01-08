//
//  WebVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebVC : HKViewController<UIWebViewDelegate>
@property (nonatomic, weak) UIViewController *originVC;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
///(Default is NO)
@property (nonatomic, assign) BOOL autoShowBackButton;
@property (nonatomic,copy)NSString * url;
@end
