#import "BaseOp.h"

@interface GascardChargeOp : BaseOp

///油卡id
@property (nonatomic,strong) NSNumber* req_gid;
///优惠劵
@property (nonatomic,strong) NSNumber* req_cid;
///充值金额
@property (nonatomic,assign) NSInteger req_amount;
///支付方式
@property (nonatomic,assign) int req_paychannel;
///支付验证码
@property (nonatomic,strong) NSString* req_vcode;
///订单id
@property (nonatomic,strong) NSNumber* req_orderid;
///是否开发票(1:开发票，0:不开)
@property (nonatomic,assign) int req_bill;

///同盾设备指纹
@property (nonatomic,copy)NSString * req_blackbox;


///交易流水
@property (nonatomic,strong) NSString* rsp_tradeid;
///记录ID
@property (nonatomic,strong) NSNumber* rsp_orderid;
///支付金额
@property (nonatomic,assign) CGFloat rsp_total;
///优惠金额
@property (nonatomic,assign) CGFloat rsp_couponmoney;


@end
