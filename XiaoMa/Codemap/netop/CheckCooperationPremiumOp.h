#import "BaseOp.h"

@interface CheckCooperationPremiumOp : BaseOp

@property (nonatomic,strong) NSNumber* req_groupid;

@property (nonatomic,strong) NSArray* rsp_licensenumbers;
@property (nonatomic,strong) NSArray* rsp_inprocesslisnums;


@end
