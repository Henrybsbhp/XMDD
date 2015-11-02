#import "BaseOp.h"

@interface GetGaschargeInfoOp : BaseOp

///油卡id
@property (nonatomic,strong) NSNumber* req_gid;

///优惠描述
@property (nonatomic,strong) NSString* rsp_desc;
///当月可充金额
@property (nonatomic,strong) NSNumber* rsp_availablechargeamt;
///已经享受过的优惠
@property (nonatomic,strong) NSNumber* rsp_couponedmoney;


@end
