//
//  HKCellData.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/27.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTQueue.h"

@interface HKCellData : NSObject
@property (nonatomic, readonly, strong) NSString *cellID;
@property (nonatomic, copy) void (^dequeuedBlock)(UITableView *tableView, UITableViewCell *cell, NSIndexPath *indexPath);
@property (nonatomic, copy) CGFloat (^heightBlock)(UITableView *tableView);
@property (nonatomic, copy) void (^selectedBlock)(UITableView *tableView, NSIndexPath *indexPath);
@property (nonatomic, strong) id tag;
@property (nonatomic, strong) id object;

- (BOOL)equalByCellID:(NSString *)cellid tag:(id)tag;
+ (HKCellData *)dataWithCellID:(NSString *)cellid tag:(id)tag;

@end
