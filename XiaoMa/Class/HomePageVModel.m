//
//  HomePageVModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HomePageVModel.h"

@interface HomePageVModel ()
{
    RACSubject *_refreshAdSubject;
}
@end
@implementation HomePageVModel

- (RACSubject *)refreshAdSubject
{
    if (!_refreshAdSubject) {
        _refreshAdSubject = [RACSubject subject];
        [[RACObserve(gMapHelper, addrComponent) distinctUntilChanged] subscribeNext:^(HKAddressComponent *component) {
            if (component) {
                [_refreshAdSubject sendNext:component];
                return ;
            }
        }];
    }
    return _refreshAdSubject;
}

@end
