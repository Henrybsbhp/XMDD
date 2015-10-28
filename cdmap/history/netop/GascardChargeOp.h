#import "BaseOp.h"

@interface GascardChargeOp : BaseOp

///油卡id
@property (nonatomic,strong) NSNumber* req_gid;
///充值金额
@property (nonatomic,assign) int req_amount;
///支付方式
@property (nonatomic,assign) int req_paychannel;
///支付验证码
@property (nonatomic,strong) NSString* req_vcode;
///订单id
@property (nonatomic,strong) NSNumber* req_orderid;

///交易流水
@property (nonatomic,strong) NSString* rsp_tradeid;
///记录ID
@property (nonatomic,strong) NSNumber* rsp_orderid;
///支付金额
@property (nonatomic,assign) int rsp_total;


@end
