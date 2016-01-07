#import "BaseOp.h"

@interface InsuranceAppointmentV2Op : BaseOp

///核保记录id
@property (nonatomic,strong) NSNumber* req_carpremiumid;
///身份证号码
@property (nonatomic,strong) NSString* req_idcard;
///投保人姓名
@property (nonatomic,strong) NSString* req_ownername;
///商业险起保日
@property (nonatomic,strong) NSString* req_startdate;
///交强险起保日
@property (nonatomic,strong) NSString* req_forcestartdate;
///保险公司代码
@property (nonatomic,strong) NSString* req_inscomp;



@end
