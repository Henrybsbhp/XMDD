//
//  MyUserStore.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/8.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CKBaseStore.h"

@interface MyUserStore : CKBaseStore
///(default is 6 * 60 * 60)
@property (nonatomic, assign) NSTimeInterval updateDuration;

/// @Override
- (void)resetForMyUser:(JTUser *)user;

/// (if key is nil, then the inner key is "$DefTimetag")
- (BOOL)needUpdateTimetagForKey:(NSString *)key;
- (void)updateTimetagForKey:(NSString *)key;
- (void)resetTimetagForKey:(NSString *)key;
- (void)resetAllTimetags;

@end
