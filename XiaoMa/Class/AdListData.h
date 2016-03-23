//
//  AdListData.h
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/22.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKAdvertisement.h"

@interface AdListData : NSObject

///根据k广告(id)查找是否在已看的记录中
+ (BOOL)checkAdAlreadyAppeard:(HKAdvertisement *)adDic;

+ (void)recordAdArray:(NSArray *)adArr;

@end
