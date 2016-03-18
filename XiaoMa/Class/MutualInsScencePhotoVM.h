//
//  MutualInsScencePhotoVM.h
//  XiaoMa
//
//  Created by RockyYe on 16/3/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MutualInsScencePhotoVM : NSObject

-(UIImage *)sampleImgForIndex:(NSInteger)index;

-(NSInteger)maxPhotoNumForIndex:(NSInteger)index;

-(NSString *)noticeForIndex:(NSInteger)index;

-(NSMutableArray *)recordArrayForIndex:(NSInteger)index;

-(NSString *)URLStringForIndex:(NSInteger)index;

-(void)deleteAllInfo;

+ (instancetype)sharedManager;

-(void)getNoticeArr;

@end
