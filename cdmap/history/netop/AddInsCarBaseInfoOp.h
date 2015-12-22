#import "BaseOp.h"

@interface AddInsCarBaseInfoOp : BaseOp

///姓名
@property (nonatomic,strong) NSString* req_name;
@property (nonatomic,strong) NSString* req_province;
@property (nonatomic,strong) NSString* req_city;
///车架号
@property (nonatomic,strong) NSString* req_frameno;
///品牌
@property (nonatomic,strong) NSString* req_brandname;
///发动机号
@property (nonatomic,strong) NSString* req_engineno;
///是否过户(0:不是 1:是)
@property (nonatomic,assign) int req_transferflag;
///过户时间
@property (nonatomic,strong) NSString* req_transferdate;
///车牌
@property (nonatomic,strong) NSString* req_licensenum;
///注册日期
@property (nonatomic,strong) NSString* req_regdate;

///核保记录id
@property (nonatomic,strong) NSNumber* rsp_carpremiumid;
///车辆座位数量
@property (nonatomic,strong) NSNumber* rsp_seatcount;


@end
