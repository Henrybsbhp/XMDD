#import "BaseOp.h"
#import "MutualInsMemberInfo2.h"

@interface GetCooperationGroupMembersOp : BaseOp

@property (nonatomic,strong) NSNumber* req_groupid;
///上次拉取记录返回的时间戳
@property (nonatomic,assign) long long req_lstupdatetime;

///当前团员人数
@property (nonatomic,assign) int rsp_membercnt;
///团员列表
@property (nonatomic,strong) NSArray* rsp_memberlist;
///最后拉取到的记录的时间戳
@property (nonatomic,assign) long long rsp_lstupdatetime;
///团描述
@property (nonatomic,strong) NSString* rsp_toptip;


@end
