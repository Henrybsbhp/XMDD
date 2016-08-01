#import "BaseOp.h"
#import "HKInsuranceOrder.h"

@interface PayForPremiumOp : BaseOp

///核保id
@property (nonatomic,strong) NSNumber* req_carpremiumid;
///投保人姓名
@property (nonatomic,strong) NSString* req_ownername;
///起保日期 DT10
@property (nonatomic,strong) NSString* req_startdate;
///交强险启保日期 DT10
@property (nonatomic,strong) NSString* req_forcestartdate;
///保险公司代码
@property (nonatomic,strong) NSString* req_inscomp;
///身份证
@property (nonatomic,strong) NSString* req_idno;
///车主联系手机
@property (nonatomic,strong) NSString* req_ownerphone;
///车主联系地址
@property (nonatomic,strong) NSString* req_owneraddress;
///省市信息
@property (nonatomic,strong) NSString* req_location;

///保险订单
@property (nonatomic,strong) HKInsuranceOrder* rsp_order;


@end
