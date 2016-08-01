//
//  MutualInsDetailVM.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CKBaseStore.h"
#import "GetCooperationGroupConfigOp.h"
#import "GetCooperationGroupMyInfoOp.h"
#import "GetCooperationGroupSharemoneyOp.h"
#import "GetCooperationGroupMembersOp.h"
#import "GetCooperationGroupMessageListOp.h"

///分页数量
extern NSInteger const kFetchPageAmount;

@interface MutualInsGroupDetailVM : CKBaseStore

@property (nonatomic, strong) NSNumber *groupID;
@property (nonatomic, strong) NSNumber *memberID;

@property (nonatomic, strong) RACSignal *reloadBaseInfoSignal;
@property (nonatomic, strong) RACSignal *reloadMyInfoSignal;
@property (nonatomic, strong) RACSignal *reloadFundInfoSignal;
@property (nonatomic, strong) RACSignal *reloadMembersInfoSignal;
@property (nonatomic, strong) RACSignal *reloadMessagesInfoSignal;

@property (nonatomic, strong) RACSignal *loadMoreMessagesInfoSignal;
@property (nonatomic, strong) RACSignal *loadMoreMembersInfoSignal;

@property (nonatomic, strong) GetCooperationGroupConfigOp *baseInfo;
@property (nonatomic, strong) GetCooperationGroupMyInfoOp *myInfo;
@property (nonatomic, strong) GetCooperationGroupSharemoneyOp *fundInfo;
@property (nonatomic, strong) GetCooperationGroupMembersOp *membersInfo;
@property (nonatomic, strong) GetCooperationGroupMessageListOp *messagesInfo;

+ (instancetype)fetchForGroupID:(NSNumber *)groupID memberID:(NSNumber *)memberID;
+ (instancetype)fetchOrCreateForGroupID:(NSNumber *)groupID memberID:(NSNumber *)memberID;

- (void)fetchBaseInfoForce:(BOOL)force;
- (void)fetchMyInfoForce:(BOOL)force;
- (void)fetchFundInfoForce:(BOOL)force;
- (void)fetchMembersInfoForce:(BOOL)force;
- (void)fetchMessagesInfoForce:(BOOL)force;

- (void)fetchMoreMessagesInfo;
- (void)fetchMoreMembersInfo;
- (BOOL)shouldUpdateTimetag:(long long)timetag forKey:(NSString *)key;
- (BOOL)saveTimetagIfNeeded:(long long)timetag forKey:(NSString *)key;

@end
