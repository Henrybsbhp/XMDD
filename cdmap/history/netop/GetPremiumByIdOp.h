#import "BaseOp.h"
#import "InsPremium.h"

@interface GetPremiumByIdOp : BaseOp

///记录id
@property (nonatomic,strong) NSNumber* req_carpremiumid;

///各保险公司报价情况
@property (nonatomic,strong) NSArray* rsp_premiumlist;
///提示
@property (nonatomic,strong) NSString* rsp_tip;


@end
