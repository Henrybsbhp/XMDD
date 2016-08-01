#import "BaseOp.h"

@interface AddCooperationGroupJoinOpOp : BaseOp

@property (nonatomic,strong) NSString* req_name;

///暗号
@property (nonatomic,strong) NSString* rsp_cipher;
///团ID
@property (nonatomic,strong) NSNumber* rsp_groupid;


@end
