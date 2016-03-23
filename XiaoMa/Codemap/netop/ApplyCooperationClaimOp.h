#import "BaseOp.h"

@interface ApplyCooperationClaimOp : BaseOp

///协议记录ID
@property (nonatomic,strong) NSString* req_claimid;
///现场图片
@property (nonatomic,strong) NSString* req_scene;
///车辆损失图片
@property (nonatomic,strong) NSString* req_cardamage;
///车辆信息图片
@property (nonatomic,strong) NSString* req_carinfo;
///Id信息图片
@property (nonatomic,strong) NSString* req_idinfo;



@end
