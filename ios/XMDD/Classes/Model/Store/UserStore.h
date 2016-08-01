//
//  UserStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/14.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "CKStore.h"
#import "JTUser.h"

@interface UserStore : CKStore
///(default is 12 * 60 * 60)
@property (nonatomic, assign) NSTimeInterval updateDuration;

///Override
- (void)reloadForUserChanged:(JTUser *)user;

///(if key is nil, then the inner key is "$DefTimetag")
- (BOOL)needUpdateTimetagForKey:(NSString *)key;
- (void)updateTimetagForKey:(NSString *)key;
- (void)resetAllTimetags;


@end
