#import "BaseOp.h"

@interface GetCZBGaschargeInfoOp : BaseOp

///油卡id
@property (nonatomic,assign) long long req_gid;
///浙商银行卡ID
@property (nonatomic,strong) NSString* req_cardid;

///当月可充金额
@property (nonatomic,assign) int rsp_availablechargeamt;
///已经享受过的优惠
@property (nonatomic,assign) int rsp_couponedmoney;
///折扣率
@property (nonatomic,assign) int rsp_discountrate;
///优惠上限
@property (nonatomic,assign) int rsp_couponupplimit;
///浙商卡已享受优惠
@property (nonatomic,assign) int rsp_czbcouponedmoney;


@end
