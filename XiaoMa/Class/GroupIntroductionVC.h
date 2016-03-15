//
//  GroupIntroductionVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    MutualGroupTypeSystem,
    MutualGroupTypeSelf,
} MutualGroupType;

@interface GroupIntroductionVC : UIViewController

@property (nonatomic, strong)NSString * titleStr;
@property (nonatomic)MutualGroupType groupType;

@end
