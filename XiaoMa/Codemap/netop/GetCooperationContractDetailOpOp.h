#import "BaseOp.h"
#import "MutualInsContract.h"

@interface GetCooperationContractDetailOpOp : BaseOp

///协议记录ID
@property (nonatomic,strong) NSNumber* req_contractid;

///协议详情
@property (nonatomic,strong) MutualInsContract* rsp_contractorder;


@end
