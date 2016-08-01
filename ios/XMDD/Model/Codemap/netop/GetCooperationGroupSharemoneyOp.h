#import "BaseOp.h"

@interface GetCooperationGroupSharemoneyOp : BaseOp

@property (nonatomic,strong) NSNumber* req_groupid;

///互助金总额
@property (nonatomic,strong) NSString* rsp_totalpoolamt;
///互助金剩余
@property (nonatomic,strong) NSString* rsp_presentpoolamt;
///互助开始时间(yyyy-MM-dd HH:ss)
@property (nonatomic,strong) NSString* rsp_insstarttime;
///互助结束时间(yyyy-MM-dd HH:ss)
@property (nonatomic,strong) NSString* rsp_insendtime;
///动态描述
@property (nonatomic,strong) NSString* rsp_tip;
///剩余互助金百分比
@property (nonatomic,strong) NSString* rsp_presentpoolpresent;


@end
