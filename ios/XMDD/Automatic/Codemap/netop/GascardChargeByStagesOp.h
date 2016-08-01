#import "GascardChargeOp.h"

@interface GascardChargeByStagesOp : GascardChargeOp

///油卡id
@property (nonatomic,strong) NSNumber* req_cardid;
///套餐id
@property (nonatomic,strong) NSNumber* req_pkgid;
///每月充值金额
@property (nonatomic,assign) int req_permonthamt;

///支付完成后的提示
@property (nonatomic,strong) NSString* rsp_tip;


@end
