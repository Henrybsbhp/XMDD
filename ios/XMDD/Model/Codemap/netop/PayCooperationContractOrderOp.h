#import "BaseOp.h"
#import "PayInfoModel.h"

@interface PayCooperationContractOrderOp : BaseOp

///协议记录ID
@property (nonatomic,strong) NSNumber* req_contractid;
///是否代买交强险
@property (nonatomic) BOOL req_proxybuy;
///优惠券ID
@property (nonatomic,strong) NSString* req_cids;
///支付渠道
@property (nonatomic)PaymentChannelType req_paychannel;
///优惠券ID
@property (nonatomic,strong) NSString* req_inscomp;

///实付金额
@property (nonatomic,assign) float rsp_total;
///交易号
@property (nonatomic,strong) NSString* rsp_tradeno;

///推送地址
@property (nonatomic,copy) NSString * rsp_notifyUrlStr;

///支付信息
@property (nonatomic,strong)PayInfoModel * rsp_payInfoModel;


@end
