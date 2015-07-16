//
//  HomePageVModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomePageVModel : NSObject
///刷新主页广告的信号(sendNext:HKAddressComponent)
- (RACSubject *)refreshAdSubject;
@end
