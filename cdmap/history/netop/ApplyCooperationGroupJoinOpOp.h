#import "BaseOp.h"

@interface ApplyCooperationGroupJoinOpOp : BaseOp

///团ID
@property (nonatomic,strong) NSNumber* req_groupid;
///爱车记录ID
@property (nonatomic,strong) NSNumber* req_carid;

///团员记录ID
@property (nonatomic,strong) NSNumber* rsp_memberid;


@end
