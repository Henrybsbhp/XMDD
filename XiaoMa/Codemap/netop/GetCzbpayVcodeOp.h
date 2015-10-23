#import "BaseOp.h"

@interface GetCzbpayVcodeOp : BaseOp

///银行卡记录ID
@property (nonatomic,strong) NSNumber* req_cardid;
///充值金额
@property (nonatomic,assign) int req_chargeamt;
///油卡id
@property (nonatomic,strong) NSNumber* req_gid;

///订单记录id
@property (nonatomic,strong) NSNumber* rsp_orderid;
///交易流水
@property (nonatomic,strong) NSString* rsp_tradeid;
@end
