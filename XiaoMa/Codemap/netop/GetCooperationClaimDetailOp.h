#import "BaseOp.h"

@interface GetCooperationClaimDetailOp : BaseOp

///理赔记录ID
@property (nonatomic,strong) NSNumber* req_claimid;

///statusdesc
@property (nonatomic,strong) NSString* rsp_statusdesc;
///status
@property (nonatomic,strong) NSString* rsp_status;
///事故时间
@property (nonatomic,strong) NSString* rsp_accidenttime;
///事故地点
@property (nonatomic,strong) NSString* rsp_accidentaddress;
///事故责任方
@property (nonatomic,strong) NSString* rsp_chargepart;
///车损概况
@property (nonatomic,strong) NSString* rsp_cardmgdesc;


@end
