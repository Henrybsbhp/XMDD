#import "BaseOp.h"

@interface GetTokenOp : BaseOp

@property (nonatomic,strong) NSString* req_phone;

@property (nonatomic,strong) NSString* rsp_token;
@property (nonatomic,assign) int rsp_expires;


@end
