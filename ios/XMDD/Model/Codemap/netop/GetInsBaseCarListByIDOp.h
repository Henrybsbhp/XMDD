#import "BaseOp.h"
#import "InsBaseCar.h"

@interface GetInsBaseCarListByIDOp : BaseOp

@property (nonatomic,strong) NSNumber* req_carpremiumid;

@property (nonatomic,strong) InsBaseCar* rsp_basecar;


@end
