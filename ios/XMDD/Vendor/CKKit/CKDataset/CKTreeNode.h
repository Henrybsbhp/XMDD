//
//  CKTreeNode.h
//  JTReader
//
//  Created by jiangjunchen on 13-12-5.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKTreeNode : NSObject
@property (nonatomic, strong) NSMutableDictionary *childNodeDict;
@property (nonatomic, weak, readonly) CKTreeNode *parentNode;
@property (nonatomic, strong, readonly) NSString *key;
@property (nonatomic, strong) id object;
+ (CKTreeNode *)nodeWithKey:(NSString *)key;
///(如果key为nil，则默认key为自身的内存地址)
- (id)initWithKey:(NSString *)key;
- (void)addChildNode:(CKTreeNode *)node;
- (NSArray *)allChildNodes;
- (CKTreeNode *)childNodeForKey:(NSString *)key;
- (void)removeChildNodeForKey:(NSString *)key;
- (void)removeAllChildNodes;
- (void)removeFromParentNode;
@end
