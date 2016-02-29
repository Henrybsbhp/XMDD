#import "BaseOp.h"

@interface GascardChargeByStagesOp : BaseOp

///油卡id
@property (nonatomic,strong) NSNumber* req_cardid;
///是否开发票(1:开发票，0:不开)
@property (nonatomic,assign) int req_bill;
///套餐id
@property (nonatomic,strong) NSNumber* req_pkgid;
///每月充值金额
@property (nonatomic,assign) int req_permonthamt;
///支付方式
@property (nonatomic,assign) int req_paychannel;
///优惠券记录id
@property (nonatomic,strong) NSNumber* req_cid;

///交易流水
@property (nonatomic,strong) NSString* rsp_tradeid;
///记录id
@property (nonatomic,strong) NSNumber* rsp_orderid;
///支付金额
@property (nonatomic,assign) float rsp_total;
///实际优惠金额
@property (nonatomic,assign) float rsp_couponmoney;
///支付完成后的提示
@property (nonatomic,strong) NSString* rsp_tip;


@end
