#import "BaseOp.h"

@interface UpdateCalculatePremiumOp : BaseOp

///记录id
@property (nonatomic,strong) NSNumber* req_carpremiumid;
///商业险起保日期
@property (nonatomic,strong) NSString* req_mstartdate;
///交强险起保日期
@property (nonatomic,strong) NSString* req_fstartdate;
///车辆信息
@property (nonatomic,strong) NSString* req_brand;



@end
