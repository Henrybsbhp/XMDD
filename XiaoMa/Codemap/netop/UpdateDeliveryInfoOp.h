#import "BaseOp.h"

@interface UpdateDeliveryInfoOp : BaseOp

///订单id
@property (nonatomic,strong) NSNumber* req_orderid;
///联系人
@property (nonatomic,strong) NSString* req_contatorname;
///联系手机
@property (nonatomic,strong) NSString* req_contatorphone;
///寄送地址
@property (nonatomic,strong) NSString* req_address;

///享受的优惠名字
@property (nonatomic,strong) NSArray* rsp_couponlist;


@end
