#import "BaseOp.h"

@interface GetCooperationConfiOp : BaseOp


///匹配团的名字
@property (nonatomic,strong) NSString* rsp_autogroupname;
///自组团的名字
@property (nonatomic,strong) NSString* rsp_selfgroupname;
///匹配团描述
@property (nonatomic,strong) NSString* rsp_autogroupdesc;
///自组团描述
@property (nonatomic,strong) NSString* rsp_selfgroupdesc;


@end
