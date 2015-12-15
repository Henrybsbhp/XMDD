//
//  UserGuideVC.m
//  XiaoMa
//
//  Created by RockyYe on 15/12/15.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "UserGuideVC.h"

@interface UserGuideVC ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation UserGuideVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
