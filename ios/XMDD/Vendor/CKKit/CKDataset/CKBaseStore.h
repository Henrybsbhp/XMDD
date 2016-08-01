//
//  CKBaseStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKBaseStore : NSObject

+ (instancetype)fetchExistsStoreForKey:(NSString *)key;
+ (instancetype)fetchOrCreateStoreForKey:(NSString *)key;
+ (instancetype)fetchExistsStore;
+ (instancetype)fetchOrCreateStore;

@end
