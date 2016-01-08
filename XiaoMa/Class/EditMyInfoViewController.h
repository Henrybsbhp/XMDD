//
//  EditMyInfoViewController.h
//  XiaoMa
//
//  Created by jt on 15-5-11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ModifyNickname = 1,
    ModifyAvatar,
    ModifySex,
    ModifyBirthday
} ModifyType;

@interface EditMyInfoViewController : HKViewController

///导航条昵称
@property (nonatomic,copy)NSString * naviTitle;
///内容
@property (nonatomic,copy)NSString * content;
///内容
@property (nonatomic,copy)NSString * placeholder;
///类型
@property (nonatomic)NSInteger type;

@end
