//
//  AwardOtherSheetVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/27.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AwardSheetType) {
    AwardSheetTypeAlreadyget,  //已经获取过红包
    AwardSheetTypeSuccess,     //获取红包成功
    AwardSheetTypeFailure      //获取红包失败
};

@interface AwardOtherSheetVC : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *carwashBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@property (nonatomic, assign) AwardSheetType sheetType;

@end
