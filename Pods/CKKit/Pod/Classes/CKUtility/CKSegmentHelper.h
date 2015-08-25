//
//  CKSegmentHelper.h
//  ROKI
//
//  Created by jiangjunchen on 14/12/18.
//  Copyright (c) 2014年 legent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKSegmentHelper : NSObject

- (void)addItem:(id<NSObject>)item
   forGroupName:(NSString *)groupName
withChangedBlock:(void(^)(id item, BOOL selected))block;

- (void)addItems:(NSArray *)items
    forGroupName:(NSString *)groupName
withChangedBlock:(void(^)(id item, BOOL selected))block;

- (void)selectItem:(id)item;
- (void)cancelSelectedForGroupName:(NSString *)name;
- (NSArray *)itemsForGroupName:(NSString *)groupName;
- (void)selectItem:(id)item forGroupName:(NSString *)name;
- (void)removeAllItemGroups;
- (void)removeAllItemsForGroupName:(NSString *)name;
- (void)removeItem:(id)item forGroupName:(NSString *)name;
- (void)setComplete:(void(^)(id item))complete forGroupName:(NSString *)name;
- (BOOL)sortAllItemsForGroupName:(NSString *)name;;

@end
