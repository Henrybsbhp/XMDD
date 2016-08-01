#import "BaseOp.h"
#import "InsCoveragePrice.h"

@interface GetPremiumDetailOp : BaseOp

@property (nonatomic,strong) NSNumber* req_carpremiumid;
///保险公司代号
@property (nonatomic,strong) NSString* req_inscomp;

@property (nonatomic,strong) NSArray* rsp_inslist;
///座位数
@property (nonatomic,assign) int rsp_setcount;
///原价
@property (nonatomic,assign) double rsp_originprice;
///实际价格
@property (nonatomic,assign) double rsp_price;
///起保日期
@property (nonatomic,strong) NSString* rsp_startdate;
///交强险启保日期 DT10
@property (nonatomic,strong) NSString* rsp_fstartdate;
///投保人
@property (nonatomic,strong) NSString* rsp_ownername;
///协议名
@property (nonatomic,strong) NSString* rsp_license;
///协议连接地址
@property (nonatomic,strong) NSString* rsp_licenseurl;
///所在省市
@property (nonatomic,strong) NSString* rsp_location;
///保险公司图片
@property (nonatomic,strong) NSString* rsp_inslogo;
///保险公司名字
@property (nonatomic,strong) NSString* rsp_inscompname;
///提示
@property (nonatomic,strong) NSString* rsp_tip;


@end
