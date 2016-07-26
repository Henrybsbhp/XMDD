#import "BaseOp.h"
#import "MutualInsMessage.h"

@interface GetCooperationGroupMessageListOp : BaseOp

@property (nonatomic,strong) NSNumber* req_groupid;
@property (nonatomic,strong) NSNumber* req_memberid;
///上次拉取记录返回的时间戳
@property (nonatomic,assign) long long req_lstupdatetime;

///动态列表
@property (nonatomic,strong) NSArray* rsp_list;
///最后拉取到的记录的时间戳
@property (nonatomic,assign) long long rsp_lstupdatetime;


@end
