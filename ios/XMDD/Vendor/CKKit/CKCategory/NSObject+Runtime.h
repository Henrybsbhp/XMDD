//
//  NSObject+Runtime.h
//  JTReader
//
//  Created by jiangjunchen on 13-10-24.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface CKWeakHolder : NSObject
+ (instancetype)holderWithObject:(id)object;
- (id)initWithObject:(id)object;
- (id)holdedObject;
@end

@interface NSObject (Runtime)

@property (nonatomic, strong) id customObject;
@property (nonatomic, strong) NSMutableDictionary *customInfo;
@property (nonatomic, strong) NSMutableArray *customArray;
@property (nonatomic, copy) void (^customActionBlock)(void);
@property (nonatomic, weak) id customWeakObject;
@property (nonatomic, assign) NSInteger customTag;
@property (nonatomic, strong) NSString *customIdenfitier;
@end

