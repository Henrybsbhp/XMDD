#import "BaseOp.h"

@interface SearchCooperationGroupOpOp : BaseOp

///暗号
@property (nonatomic,strong) NSString* req_cipher;

///团名称
@property (nonatomic,strong) NSString* rsp_name;
///团长昵称
@property (nonatomic,strong) NSString* rsp_creatorname;
///团ID
@property (nonatomic,strong) NSNumber* rsp_groupid;


@end
