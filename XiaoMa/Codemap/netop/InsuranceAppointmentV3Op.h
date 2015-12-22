#import "BaseOp.h"

@interface InsuranceAppointmentV3Op : BaseOp

///车牌号
@property (nonatomic,strong) NSString* req_licenseno;
///身份证号码
@property (nonatomic,strong) NSString* req_idcard;
///行驶证正面
@property (nonatomic,strong) NSString* req_driverpic;
///购买险种列表
@property (nonatomic,strong) NSString* req_inslist;



@end
