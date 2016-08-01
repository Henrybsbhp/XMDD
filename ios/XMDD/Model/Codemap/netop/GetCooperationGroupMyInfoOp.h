#import "BaseOp.h"

@interface GetCooperationGroupMyInfoOp : BaseOp

@property (nonatomic,strong) NSNumber* req_groupid;
@property (nonatomic,strong) NSNumber* req_memberid;

///车牌号码
@property (nonatomic,strong) NSString* rsp_licensenumber;
///车辆品牌图标url
@property (nonatomic,strong) NSString* rsp_carlogourl;
///状态 (0：团长无车。1：待完善资料。3：审核中。5:待支付。6：支付完成。7：互助中。8：保障中。20：重新上传)
@property (nonatomic,assign) int rsp_status;
///状态描述
@property (nonatomic,strong) NSString* rsp_statusdesc;
///当前金额
@property (nonatomic,strong) NSString* rsp_fee;
///当前金额描述
@property (nonatomic,strong) NSString* rsp_feedesc;
///帮助他人金额
@property (nonatomic,strong) NSString* rsp_helpfee;
///补偿次数
@property (nonatomic,assign) int rsp_claimcnt;
///补偿金额
@property (nonatomic,strong) NSString* rsp_claimfee;
///保障开始时间
@property (nonatomic,strong) NSString* rsp_insstarttime;
///保障结束时间
@property (nonatomic,strong) NSString* rsp_insendtime;
///互助金
@property (nonatomic,strong) NSString* rsp_sharemoney;
///会员费
@property (nonatomic,strong) NSString* rsp_servicefee;
///交强险
@property (nonatomic,strong) NSString* rsp_forcefee;
///车船税
@property (nonatomic,strong) NSString* rsp_shiptaxfee;
///动态描述
@property (nonatomic,strong) NSString* rsp_tip;
///查看我的协议地址(只有status为，7,8该值不为空)
@property (nonatomic,strong) NSString* rsp_contracturl;
///按钮名字
@property (nonatomic,strong) NSString* rsp_buttonname;
///用户车辆id
@property (nonatomic,strong) NSNumber* rsp_usercarid;


@end
