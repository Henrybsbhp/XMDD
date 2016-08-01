//
//  AutoInfoModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AutoBrand+Extension.h"

@interface AutoInfoModel : NSObject

//获取最新的汽车品牌信息
- (NSFetchedResultsController *)createAutoBrandFetchCtrl;
- (RACSignal *)rac_updateAutoBrand;
- (void)cleanAutoBrandTimetag;

@end
