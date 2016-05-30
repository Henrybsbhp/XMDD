#import "BaseOp.h"
#import "MutualInsMemberInfo.h"

@interface GetCooperationMygroupDetailOp : BaseOp

///团员记录ID
@property (nonatomic,strong) NSNumber* req_memberid;
///团ID
@property (nonatomic,strong) NSNumber* req_groupid;

///团员其他人的信息
@property (nonatomic,strong) NSArray* rsp_members;
///各阶段有效时间
@property (nonatomic,strong) NSString* rsp_timeperiod;
///自己记录状态描述
@property (nonatomic,strong) NSString* rsp_selfstatusdesc;
///控制状态栏显示
@property (nonatomic,assign) int rsp_barstatus;
@property (nonatomic,assign) int rsp_status;
///协议记录ID
@property (nonatomic,strong) NSNumber* rsp_contractid;
///剩余时间倒计时提示语
@property (nonatomic,strong) NSString* rsp_timetip;
///池子最大金额
@property (nonatomic,assign) float rsp_totalpoolamt;
///池子当前金额
@property (nonatomic,assign) float rsp_presentpoolamt;
///各种状态倒计时剩余时间
@property (nonatomic,assign) long long rsp_lefttime;
///没有车直接报价按钮是否显示
@property (nonatomic,assign) int rsp_pricebuttonflag;
///按钮名字
@property (nonatomic,strong) NSString* rsp_buttonname;
///是否当前人是团长本人
@property (nonatomic,assign) BOOL rsp_ifgroupowner;
///团长是否有车
@property (nonatomic,assign) BOOL rsp_ifownerhascar;
///团记录ID
@property (nonatomic,strong) NSNumber* rsp_groupid;
///核价按钮名字
@property (nonatomic,strong) NSString* rsp_pricebuttonname;
///是否显示邀请好友(1：显示，0：不显示)
@property (nonatomic,assign) int rsp_invitebtnflag;
///团名
@property (nonatomic,strong) NSString* rsp_groupname;
///团类型(1：自助，2：匹配)
@property (nonatomic,assign) int rsp_type;
///显示补偿记录按钮标志(0：不显示，1：显示)
@property (nonatomic,assign) int rsp_claimbtnflag;
///我的协议地址(只有status为7，8时有效)
@property (nonatomic,strong) NSString* rsp_contracturl;


@end
