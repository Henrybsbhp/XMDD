#import "BaseOp.h"
#import "MutualInsClaimInfo.h"

@interface GetCooperationClaimsListOpOp : BaseOp


///理赔详情
@property (nonatomic,strong) MutualInsClaimInfo* rsp_claimlist;


@end
