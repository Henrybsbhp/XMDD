//
//  DetailWebVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/10/21.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailWebVC : HKViewController

@property (nonatomic, weak) UIViewController *originVC;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) NSString *tradeno;
@property (nonatomic, strong) RACSubject *subject;

- (void)requestUrl:(NSString *)url;


@end
