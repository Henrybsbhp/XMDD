#import "BaseOp.h"

@interface GetCooperationMemberDetailOpOp : BaseOp

///团员记录ID
@property (nonatomic,strong) NSNumber* req_memberid;

///车牌
@property (nonatomic,strong) NSString* rsp_licensenumber;
///车主手机
@property (nonatomic,strong) NSString* rsp_phone;
///品牌车系信息
@property (nonatomic,strong) NSString* rsp_carbrand;
///互助资金
@property (nonatomic,assign) float rsp_sharemoney;
///所占比例
@property (nonatomic,assign) int rsp_rate;
///可返金额
@property (nonatomic,assign) float rsp_returnmoney;


@end
