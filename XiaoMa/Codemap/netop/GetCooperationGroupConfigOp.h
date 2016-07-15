#import "BaseOp.h"

@interface GetCooperationGroupConfigOp : BaseOp

@property (nonatomic,strong) NSNumber* req_groupid;
@property (nonatomic,strong) NSNumber* req_memberid;

///是否可以退团 (0：否 1：是)
@property (nonatomic,assign) int rsp_isexist;
///显示邀请按钮标示 (0：不显示 1：显示)
@property (nonatomic,assign) int rsp_invitebtnflag;
///团详情使用帮助地址
@property (nonatomic,strong) NSString* rsp_helpurl;
///显示补偿记录按钮标示 (0：不显示， 1：显示)
@property (nonatomic,assign) int rsp_claimbtnflag;
///互助金最新更新时间
@property (nonatomic,assign) long long rsp_huzhulstupdatetime;
///动态最新更新时间
@property (nonatomic,assign) long long rsp_newslstupdatetime;
///团名称
@property (nonatomic,strong) NSString* rsp_groupname;
///团员在团的状态，控制按钮跳转页面
@property (nonatomic,assign) int rsp_status;
///协议记录ID
@property (nonatomic,strong) NSNumber* rsp_contractid;
///是否当前人是团长本人(0：不是， 1：是)
@property (nonatomic,assign) int rsp_ifgroupowner;
///是否可以删团 (0：否。1：是)
@property (nonatomic,assign) int rsp_isdelete;
///是否显示“我 (0：否。1：是)
@property (nonatomic,assign) int rsp_showselfflag;


@end
