#import "BaseOp.h"
#import "MutualInsClaimInfo.h"

@interface GetCooperationClaimsListOp : BaseOp

@property (nonatomic,strong) NSNumber *req_gid;

///理赔详情
@property (nonatomic,strong) NSArray *rsp_claimlist;


@end
