//
//  MutualInsAdPicVC.h
//  XiaoMa
//
//  Created by RockyYe on 16/7/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MutualInsAdModel.h"

@interface MutualInsAdPicVC : UIViewController

@property (strong, nonatomic) UIImage *img;

@property (strong, nonatomic) NSString *adLink;

@property (assign, nonatomic) BOOL userInteractionEnabled;

@property (strong, nonatomic) MutualInsAdModel *model;

@end
