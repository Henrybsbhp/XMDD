#import "BaseOp.h"

@interface UpdateCooperationInsInfoOp : BaseOp

///投保保险信息列表
@property (nonatomic,strong) NSString* req_inslist;
///团员记录ID
@property (nonatomic,strong) NSNumber* req_memberid;
///是否愿意代买
@property (nonatomic,strong) NSNumber* req_proxybuy;



@end
