#import "BaseOp.h"

@interface UpdateCooperationIdlicenseInfoOp : BaseOp

///身份证地址
@property (nonatomic,strong) NSString* req_idurl;
///行驶证地址
@property (nonatomic,strong) NSString* req_licenseurl;
///最近一次保险公司名字
@property (nonatomic,strong) NSString* req_firstinscomp;
///再上一次保险公司名字
@property (nonatomic,strong) NSString* req_secinscomp;
///团员记录ID
@property (nonatomic,strong) NSString* req_memberid;
///商业险到期日
@property (nonatomic,strong) NSString* req_insenddate;



@end
