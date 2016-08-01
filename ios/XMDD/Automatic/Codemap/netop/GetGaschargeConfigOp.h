#import "BaseOp.h"
#import "GasChargePackage.h"

@interface GetGaschargeConfigOp : BaseOp


///描述
@property (nonatomic,copy) NSString* rsp_desc;
///折扣率
@property (nonatomic,assign) int rsp_discountrate;
///有优惠充值上限
@property (nonatomic,assign) int rsp_couponupplimit;
///充值上限
@property (nonatomic,strong) NSNumber * rsp_chargeupplimit;
///加油公告
@property (nonatomic,strong) NSString* rsp_tip;
///分期可充值金额列表
@property (nonatomic,strong) NSArray* rsp_supportamt;
///折扣方案
@property (nonatomic,strong) NSArray* rsp_packages;

///生成所有充值套餐数组（包含普通充值，普通充值的月份数为1）
- (NSArray *)generateAllChargePackages;

@end
