#import "BaseOp.h"
#import "MutualInsMemberInfo.h"

@interface GetCooperationMygroupDetailOp : BaseOp

///团员记录ID
@property (nonatomic,strong) NSNumber* req_memberid;
///团ID
@property (nonatomic,strong) NSNumber* req_groupid;

///团员其他人的信息
@property (nonatomic,strong) NSArray* rsp_members;
///各阶段有效时间
@property (nonatomic,strong) NSString* rsp_timeperiod;
///自己记录状态描述
@property (nonatomic,strong) NSString* rsp_selfstatusdesc;


@end
