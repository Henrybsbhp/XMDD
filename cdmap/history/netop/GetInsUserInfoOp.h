#import "BaseOp.h"

@interface GetInsUserInfoOp : BaseOp

///订单id
@property (nonatomic,strong) NSNumber* req_orderid;

///被保人名字
@property (nonatomic,strong) NSString* rsp_name;
///被保人手机
@property (nonatomic,strong) NSString* rsp_phone;
///所在省市
@property (nonatomic,strong) NSString* rsp_location;
///具体地址信息
@property (nonatomic,strong) NSString* rsp_address;


@end
