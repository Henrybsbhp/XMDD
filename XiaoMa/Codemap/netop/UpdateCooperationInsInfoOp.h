#import "BaseOp.h"

@interface UpdateCooperationInsInfoOp : BaseOp

///团员记录ID
@property (nonatomic,strong) NSNumber *req_memberid;
///是否愿意代买
@property (nonatomic,strong) NSNumber *req_proxybuy;



@end
