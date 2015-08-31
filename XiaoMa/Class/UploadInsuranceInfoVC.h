//
//  UploadInsuranceInfoVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadInsuranceInfoVC : UIViewController

///完成事件（返回下一个ViewController，如果为nil则不跳转）
@property (nonatomic, copy) UIViewController *(^finishBlock)(BOOL skip, UIViewController *targetvc);
///(default is YES)
@property (nonatomic, assign) BOOL allowSkip;

@end
