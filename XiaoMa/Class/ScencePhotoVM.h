//
//  ScencePhotoVM.h
//  XiaoMa
//
//  Created by RockyYe on 16/3/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScencePhotoVM : NSObject

-(UIImage *)sampleImgForIndex:(NSInteger)index;

-(NSInteger)maxPhotoNumForIndex:(NSInteger)index;

-(NSString *)noticeForIndex:(NSInteger)index;

-(NSMutableArray *)imgArrForIndex:(NSInteger)index;

-(NSMutableArray *)urlArrForIndex:(NSInteger)index;

-(void)deleteAllInfo;

+ (instancetype)sharedManager;
@end
