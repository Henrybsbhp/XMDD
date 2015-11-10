#import "BaseOp.h"

@interface GetCZBGaschargeInfoOp : BaseOp

///油卡id
@property (nonatomic,strong) NSNumber* req_gid;
///浙商银行卡ID
@property (nonatomic,strong) NSNumber* req_cardid;
///当月可充金额
@property (nonatomic,assign) int rsp_availablechargeamt;
///已经享受过的优惠
@property (nonatomic,assign) int rsp_couponedmoney;
///优惠描述
@property (nonatomic,strong) NSString* rsp_desc;
///折扣率
@property (nonatomic,assign) int rsp_discountrate;
///优惠上限
@property (nonatomic,assign) int rsp_couponupplimit;
///浙商卡已享受优惠
@property (nonatomic,assign) int rsp_czbcouponedmoney;
///加油上限
@property (nonatomic,assign) int rsp_chargeupplimit;


@end
