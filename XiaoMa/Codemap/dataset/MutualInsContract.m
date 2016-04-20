#import "MutualInsContract.h"
  
@implementation MutualInsContract


+ (instancetype)createWithJSONDict:(NSDictionary *)dict
{
    MutualInsContract *obj = [[self alloc] init];
    [obj resetWithJSONDict:dict];
    return obj;
}

- (void)resetWithJSONDict:(NSDictionary *)dict
{
    self.contractid = dict[@"contractid"];
    self.status = [dict[@"status"] intValue];
    self.insurancedname = dict[@"insurancedname"];
    self.contractperiod = dict[@"contractperiod"];
    self.licencenumber = dict[@"licencenumber"];
    self.idno = dict[@"idno"];
    self.total = [dict[@"total"] floatValue];
    self.couponmoney = [dict[@"couponmoney"] floatValue];
    self.inslist = dict[@"inslist"];
    self.insperiod = dict[@"insperiod"];
    self.forcefee = [dict[@"forcefee"] floatValue];
    self.taxshipfee = [dict[@"taxshipfee"] floatValue];
    self.inscomp = dict[@"inscomp"];
    self.totalmonth = dict[@"totalmonth"];
    self.xmddlogo = dict[@"xmddlogo"];
    self.xmddname = dict[@"xmddname"];
    self.remindtip = dict[@"remindtip"];
    self.couponname = dict[@"couponname"];
    self.couponlist = dict[@"couponlist"];
    self.finishaddress = [dict boolParamForName:@"finishaddress"];
    self.insnotes = dict[@"insnotes"];
}

@end

