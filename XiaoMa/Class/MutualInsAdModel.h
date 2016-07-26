//
//  MutualInsAdModel.h
//  XiaoMa
//
//  Created by RockyYe on 16/7/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MutualInsAdModel : NSObject

- (void)getSystemPromotion;

@property (strong, nonatomic) NSMutableArray *imgArr;

@property (strong, nonatomic) NSString *imgStr;

@property (strong, nonatomic) NSString *adLink;

@property (assign, nonatomic) CGFloat imgCount;

@property (assign, nonatomic) BOOL haveRetry;

@end
