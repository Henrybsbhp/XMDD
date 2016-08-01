#import "BaseOp.h"

@interface GetCoorperationClaimConfigOp : BaseOp


///现场照片注意事项描述
@property (nonatomic,strong) NSString* rsp_scenedesc;
///车损信息注意事项描述
@property (nonatomic,strong) NSString* rsp_cardamagedesc;
///车辆信息注意事项描述
@property (nonatomic,strong) NSString* rsp_carinfodesc;
///身份证信息注意事项描述
@property (nonatomic,strong) NSString* rsp_idinfodesc;


@end
