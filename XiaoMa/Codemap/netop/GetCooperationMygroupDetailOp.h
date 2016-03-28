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
//1：待上传 (ifgroupowner==1,则需要显示无车，或者完善资料按钮)
//2：待审核
//3：待报价
//4：待支付
//0：不用显示状态栏
///控制状态栏显示
@property (nonatomic,assign) int rsp_barstatus;
//0：完善爱车信息（团长特有）
//1：完善行驶证信息,
//2：完善保险列表信息
//3，资料审核中（无按钮）
//20,资料审核不通过，请重新上传
//21，资料审核不通过，无法加入该团。原因：xxxx
//4. 审核通过等待，团长报价（团员）
//100 全员资料审核通过，可进行精准核价（立即核价）团长特有
//5 您需要支付xxx元，支付倒计时12小时12分（立即支付）
//6 支付成功，等待其他团员支付，支付倒计时12小时12分
//101 全部团员支付成功，组团结束。协议将于2016年3月1日生效（无按钮）
//7. 协议已出
//8 协议生效中，如有任何疑问，可拨打客服电话咨询（联系客服）
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
///用于暂存接口返回时的时间戳
@property (nonatomic, assign) NSTimeInterval tempTimetag;
///团名
@property (nonatomic,strong) NSString* rsp_groupname;
@end
