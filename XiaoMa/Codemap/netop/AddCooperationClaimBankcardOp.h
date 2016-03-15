#import "BaseOp.h"

@interface AddCooperationClaimBankcardOp : BaseOp

///理赔记录ID
@property (nonatomic,strong) NSString* req_cardno;
///发卡行
@property (nonatomic,strong) NSString* req_issuebank;

///银行卡记录ID
@property (nonatomic,strong) NSString* rsp_cardid;


@end
