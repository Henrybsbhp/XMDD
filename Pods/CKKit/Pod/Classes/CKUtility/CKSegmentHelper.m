//
//  CKSegmentHelper.m
//  ROKI
//
//  Created by jiangjunchen on 14/12/18.
//  Copyright (c) 2014年 legent. All rights reserved.
//

#import "CKSegmentHelper.h"
#import "CKCategory.h"
#import <objc/runtime.h>

static char sGroupCompleteBlockKey;

@interface CKSegmentHelper ()
@property (nonatomic, strong) NSMutableDictionary *itemGroups;
@end
@implementation CKSegmentHelper
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.itemGroups = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addItems:(NSArray *)items forGroupName:(NSString *)groupName withChangedBlock:(void (^)(id, BOOL))block
{
    for (id item in items){
        [self addItem:item forGroupName:groupName withChangedBlock:block];
    }
}

- (void)addItem:(id<NSObject>)item
   forGroupName:(NSString *)groupName
withChangedBlock:(void(^)(id item, BOOL selected))block
{
    NSMutableArray *group = [self itemGroupForName:groupName];
    [[(NSObject *)item customInfo] safetySetObject:[block copy] forKey:@"$segment-block"];
    [[(NSObject *)item customInfo] safetySetObject:groupName forKey:@"$segment-group-name"];
    
    if (![group containsObject:item]) {
        [group safetyAddObject:item];
    }
}

- (void)selectItem:(id)item
{
    NSString *groupName = [[(NSObject *)item customInfo] objectForKey:@"$segment-group-name"];
    [self selectItem:item forGroupName:groupName];
}

- (void)cancelSelectedForGroupName:(NSString *)name
{
    [self selectItem:nil forGroupName:name];
}

- (void)selectItem:(id)item forGroupName:(NSString *)name
{
    NSMutableArray *group = [self itemGroupForName:name];
    for (NSObject *curItem in group) {
        BOOL selected = [curItem isEqual:item];
        [self changeItemState:curItem withSelected:selected];
    }
    void (^complete)(id) = objc_getAssociatedObject(group, &sGroupCompleteBlockKey);
    if (complete) {
        complete(item);
    }
}

- (NSArray *)itemsForGroupName:(NSString *)groupName
{
    return [self itemGroupForName:groupName];
}

- (void)removeAllItemGroups
{
    [self.itemGroups removeAllObjects];
}

- (void)removeAllItemsForGroupName:(NSString *)name
{
    NSMutableArray *group = [self itemGroupForName:name];
    [group removeAllObjects];
}

- (void)removeItem:(id)item forGroupName:(NSString *)name
{
    NSMutableArray *group = [self itemGroupForName:name];
    [group safetyRemoveObject:item];
}

- (void)setComplete:(void(^)(id item))complete forGroupName:(NSString *)name
{
    NSMutableArray *group = [self itemGroupForName:name];
    objc_setAssociatedObject(group, &sGroupCompleteBlockKey, complete, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark - Pravite
- (BOOL)isItemSelected:(NSObject *)item
{
    NSNumber *number = [[item customInfo] objectForKey:@"$segment-selected"];
    return [number boolValue];
}

- (void)changeItemState:(NSObject *)item withSelected:(BOOL)selected
{
    void(^block)(id, BOOL) = [[(NSObject *)item customInfo] objectForKey:@"$segment-block"];
    if (block) {
        block(item, selected);
    }
    //如果状态未改变则不做处理
    if ([self isItemSelected:item] == selected) {
        return;
    }
    if (!selected) {
        [[item customInfo] removeObjectForKey:@"$segment-selected"];
    }
    else {
        [[item customInfo] setObject:@YES forKey:@"$segment-selected"];
    }
}

- (NSMutableArray *)itemGroupForName:(NSString *)name
{
    name = name ? name : @"$";
    NSMutableArray *group = [self.itemGroups objectForKey:name];
    if (!group) {
        group = [NSMutableArray array];
        [self.itemGroups setObject:group forKey:name];
    }
    return group;
}

//- (BOOL)sortAllItemsForGroupName:(NSString *)name byComparisonResult:(NSComparisonResult)c
//{
//    name = name ? name : @"$";
//    NSMutableArray *group = [self.itemGroups objectForKey:name];
//    [group sortedArrayUsingComparator:^NSComparisonResult(NSObject *obj1, NSObject *obj2) {
//        
//        
//        if (c == NSOrderedAscending)
//            return
//    }];
//}


@end
