#import "BaseOp.h"
#import "InsPremium.h"

@interface CalculatePremiumOp : BaseOp

///记录id
@property (nonatomic,strong) NSNumber* req_carpremiumid;
///选中的保险列表
@property (nonatomic,strong) NSString* req_inslist;
///商业险起保日期
@property (nonatomic,strong) NSString* req_mstartdate;
///交强险起保日期
@property (nonatomic,strong) NSString* req_fstartdate;

///各保险公司报价情况
@property (nonatomic,strong) NSArray* rsp_premiumlist;

@property (nonatomic,copy)NSString *rsp_tip;


@end
