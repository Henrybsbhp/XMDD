#import "BaseOp.h"
#import "InsCoveragePrice.h"

@interface GetPremiumDetailOpOp : BaseOp

@property (nonatomic,strong) NSNumber* req_carpremiumid;
///保险公司代号
@property (nonatomic,strong) NSString* req_inscomp;

@property (nonatomic,strong) NSArray* rsp_inslist;
///座位数
@property (nonatomic,assign) int rsp_setcount;
///原价
@property (nonatomic,strong) NSString* rsp_originprice;
///实际价格
@property (nonatomic,strong) NSString* rsp_price;
///起保日期
@property (nonatomic,strong) NSString* rsp_startdate;
///投保人
@property (nonatomic,strong) NSString* rsp_ownername;
///保险公司图片
@property (nonatomic,strong) NSString* rsp_inslogo;
///保险公司名字
@property (nonatomic,strong) NSString* rsp_inscompname;
///提示
@property (nonatomic,strong) NSString* rsp_tip;


@end
