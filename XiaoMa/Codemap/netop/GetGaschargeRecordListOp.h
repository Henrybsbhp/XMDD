#import "BaseOp.h"
#import "GasChargeRecord.h"

@interface GetGaschargeRecordListOp : BaseOp

///支付时间戳
@property (nonatomic,assign) long long req_payedtime;

///加油记录列表
@property (nonatomic,strong) NSArray* rsp_gaschargeddatas;
///当年充值总额
@property (nonatomic,assign) int rsp_charegetotal;
///总计优惠额
@property (nonatomic,assign) int rsp_couponedtotal;


@end
