#import "BaseOp.h"
#import "InsBaseCar.h"

@interface GetInsBaseCarListOp : BaseOp

@property (nonatomic,strong) NSString* req_name;
@property (nonatomic,strong) NSString* req_licensenum;
@property (nonatomic,strong) NSNumber* req_carid;

@property (nonatomic,strong) InsBaseCar* rsp_basecar;


@end
