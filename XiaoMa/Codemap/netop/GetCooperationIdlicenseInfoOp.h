#import "BaseOp.h"


@interface GetCooperationIdlicenseInfoOp : BaseOp

///团ID
@property (nonatomic,strong) NSNumber* req_memberId;

///行驶证图片
@property (nonatomic,strong) NSString* rsp_licenseurl;
///身份证图片
@property (nonatomic,strong) NSString* rsp_idnourl;
///上期保险公司名字
@property (nonatomic,strong) NSString* rsp_lstinscomp;
///上期保险公司名字
@property (nonatomic,strong) NSString* rsp_secinscomp;
///商业险到期日
@property (nonatomic,strong) NSDate* rsp_insenddate;
///商业险到期日(系统设置的最小值)
@property (nonatomic,strong) NSDate* rsp_mininsenddate;


@end
