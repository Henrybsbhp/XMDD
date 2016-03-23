#import "BaseOp.h"

@interface ApplyCooperationClaimOp : BaseOp

///协议记录ID
@property (nonatomic,strong) NSString* req_licensenumber;
///现场图片
@property (nonatomic,strong) NSArray* req_scene;
///车辆损失图片
@property (nonatomic,strong) NSArray* req_cardamage;
///车辆信息图片
@property (nonatomic,strong) NSArray* req_carinfo;
///Id信息图片
@property (nonatomic,strong) NSArray* req_idinfo;

///实付金额
@property (nonatomic,assign) float rsp_total;
///交易号
@property (nonatomic,strong) NSString* rsp_tradeno;


@end
