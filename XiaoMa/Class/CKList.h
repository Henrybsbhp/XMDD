//
//  CKList.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/4/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CKQueue.h"

@protocol CKItemDelegate <NSObject>

- (id<NSCopying>)key;
- (instancetype)setKey:(id<NSCopying>)key;

@end



@interface CKList : CKQueue<CKItemDelegate>

+ (instancetype)list;
+ (instancetype)listWithArray:(NSArray *)array;

@end



@interface CKDict : NSObject<CKItemDelegate>

@property (nonatomic, assign) BOOL forceReload;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (CKDict *)dictWithCKDict:(CKDict *)dict;
+ (CKDict *)dictWith:(NSDictionary *)dict;
- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying >)aKey;
- (id)objectForKeyedSubscript:(id)key;

@end


