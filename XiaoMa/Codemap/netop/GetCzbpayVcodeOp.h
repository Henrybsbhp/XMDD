#import "BaseOp.h"

@interface GetCzbpayVcodeOp : BaseOp

///电话
@property (nonatomic,strong) NSString* req_phone;
///银行卡记录ID
@property (nonatomic,strong) NSNumber* req_cardid;

@end
