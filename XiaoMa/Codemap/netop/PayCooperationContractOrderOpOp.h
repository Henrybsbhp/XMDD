#import "BaseOp.h"

@interface PayCooperationContractOrderOpOp : BaseOp

///协议记录ID
@property (nonatomic,strong) NSNumber* req_contractid;
///是否代买交强险
@property (nonatomic,strong) NSNumber* req_proxybuy;
///优惠券ID
@property (nonatomic,strong) NSNumber* req_cid;
///支付渠道
@property (nonatomic,strong) NSString* req_paychannel;

///实付金额
@property (nonatomic,assign) float rsp_total;
///交易号
@property (nonatomic,strong) NSString* rsp_tradeno;


@end
