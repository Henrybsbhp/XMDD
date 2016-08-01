#import "BaseOp.h"

@interface UpdateCooperationContractDeliveryinfoOp : BaseOp

///协议记录ID
@property (nonatomic,strong) NSNumber* req_contractid;
///联系人名
@property (nonatomic,strong) NSString* req_contactname;
///联系人手机
@property (nonatomic,strong) NSString* req_contactphone;
///联系地址
@property (nonatomic,strong) NSString* req_address;



@end
