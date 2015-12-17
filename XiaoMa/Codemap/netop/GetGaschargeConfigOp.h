#import "BaseOp.h"

@interface GetGaschargeConfigOp : BaseOp


///描述
@property (nonatomic,copy) NSString* rsp_desc;
///折扣率
@property (nonatomic,assign) int rsp_discountrate;
///有优惠充值上限
@property (nonatomic,assign) int rsp_couponupplimit;
///充值上限
@property (nonatomic,assign) int rsp_chargeupplimit;
///公告
@property (nonatomic,copy) NSString* rsp_announce;

@end
