#import "BaseOp.h"

@interface AddGascardOp : BaseOp

///油卡卡号
@property (nonatomic,strong) NSString* req_gascardno;
///油卡类型
@property (nonatomic,assign) int req_cardtype;

///油卡id
@property (nonatomic,strong) NSNumber* rsp_gid;
///当月可以充值金额
@property (nonatomic,strong) NSNumber* rsp_availablechargeamt;
///当月已经享受优惠金额
@property (nonatomic,strong) NSNumber* rsp_couponedmoney;


@end
