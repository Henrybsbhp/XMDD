//
//  MutualInsScencePhotoVC.h
//  XiaoMa
//
//  Created by RockyYe on 16/3/9.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MutualInsScencePhotoVM.h"
@interface MutualInsScencePhotoVC : UIViewController

@property (nonatomic) NSInteger index;

@property (nonatomic,strong) MutualInsScencePhotoVM *scencePhotoVM;

@property (nonatomic,strong) NSArray *noticeArr;

-(NSString *)canPush;

@end
