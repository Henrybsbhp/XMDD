#import "BaseOp.h"

@interface GetGaschargeInfoOp : BaseOp

///油卡id
@property (nonatomic,assign) long long req_gid;

///当月可充金额
@property (nonatomic,strong) NSString* rsp_availablechargeamt;
///已经享受过的优惠
@property (nonatomic,assign) int rsp_couponedmoney;


@end
