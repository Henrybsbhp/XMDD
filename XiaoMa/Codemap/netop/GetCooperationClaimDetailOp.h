#import "BaseOp.h"

@interface GetCooperationClaimDetailOp : BaseOp

///理赔记录ID
@property (nonatomic,strong) NSNumber* req_claimid;

///statusdesc
@property (nonatomic,strong) NSString* rsp_statusdesc;
///status
@property (nonatomic,strong) NSNumber* rsp_status;
///事故时间
@property (nonatomic,strong) NSString* rsp_accidenttime;
///事故地点
@property (nonatomic,strong) NSString* rsp_accidentaddress;
///事故责任方
@property (nonatomic,strong) NSString* rsp_chargepart;
///车损概况
@property (nonatomic,strong) NSString* rsp_cardmgdesc;
///理由
@property (nonatomic,strong) NSString* rsp_reason;
///预估理赔费用
@property (nonatomic) CGFloat rsp_claimfee;
///最近一次理赔银行卡记录ID
@property (nonatomic,strong) NSNumber* rsp_cardid;
///理赔卡名
@property (nonatomic,strong) NSString* rsp_cardname;

@end
