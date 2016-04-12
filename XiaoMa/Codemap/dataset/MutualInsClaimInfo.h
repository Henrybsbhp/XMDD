#import <Foundation/Foundation.h>

@interface MutualInsClaimInfo : NSObject
///理赔记录ID
@property (nonatomic,strong) NSNumber* claimid;
///理赔详细状态 1：理赔记录待处理 2：待确认金额 3：理赔待打款 4：理赔完成打款，已结束
@property (nonatomic,assign) int detailstatus;
///理赔状态描述
@property (nonatomic,strong) NSString* detailstatusdesc;
///理赔概要状态描述
@property (nonatomic,strong) NSString* statusdesc;
///事故描述
@property (nonatomic,strong) NSString* accidentdesc;
///理赔费用
@property (nonatomic,assign) float claimfee;
///记录最近更新时间
@property (nonatomic,strong) NSNumber* lstupdatetime;
///车牌号
@property (nonatomic,strong) NSString* licensenum;


+ (instancetype)createWithJSONDict:(NSDictionary *)dict;
- (void)resetWithJSONDict:(NSDictionary *)dict;

@end
