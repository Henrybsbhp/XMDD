#import "BaseOp.h"

@interface GetCZBCouponDefInfoOp : BaseOp


///描述
@property (nonatomic,strong) NSString* rsp_desc;
///充值上限
@property (nonatomic,assign) NSInteger rsp_chargeupplimit;


@end
