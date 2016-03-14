#import "BaseOp.h"

@interface ApplyCooperationGroupJoinOp : BaseOp

@property (nonatomic,strong) NSNumber* req_groupid;
@property (nonatomic,strong) NSNumber* req_carid;

@property (nonatomic,strong) NSNumber* rsp_memberid;


@end
