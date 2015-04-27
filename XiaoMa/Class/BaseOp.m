//
//  BaseOp.m
//  HappyTrain
//
//  Created by jt on 14-10-29.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import "BaseOp.h"
#import "NSString+MD5.h"
#import "AFHTTPRequestOperationManager+ReactiveCocoa.h"

@interface BaseOp()
@property (nonatomic, strong) NSHTTPURLResponse *response;
@end

@implementation BaseOp
@synthesize simulateResponse = _simulateResponse;
@synthesize simulateResponseDelay = _simulateResponseDelay;



static int32_t g_requestId = 1;
static int32_t g_requestVid = 1;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _simulateResponse = gNetworkMgr.simulateResponse;
        _simulateResponseDelay = gNetworkMgr.simulateResponseDelay;
    }
    return self;
}

- (void)increaseRequistIDs
{
    self.req_id = g_requestId++;
    self.req_vid = g_requestVid++;
}

- (RACSignal *)rac_invokeWithRPCClient:(AFHTTPRequestOperationManager *)manager params:(id)params security:(BOOL)security
{
    [self increaseRequistIDs];
    if (security)
    {
        params = [self addSecurityParamsFrom:params];
    }
    
    if (self.simulateResponse) {
        DebugLog(@"%@模拟 %@\nmethod:%@ (id:%d)\nParams:%@",
                 kReqPrefix, manager.baseURL, self.req_method, self.req_id, params);
        return [self rac_simulateResponse];
    }
    
    AFHTTPRequestOperation *af_op;
    RACSignal *sig = [[[[manager rac_invokeMethod:self.req_method parameters:params requestId:@(self.req_id) operation:&af_op] flattenMap:^RACStream *(RACTuple *tuple) {

        AFHTTPRequestOperation *op = tuple.first;
        self.rsp_statusCode = op.response.statusCode;
        self.rsp_error = nil;
        self.response = op.response;
        id rsp = [self filterNSNullForParentObject:nil addNewObject:tuple.second withKey:nil fromOldObject:nil];
        id rst = [self parseDefaultResponseObject:rsp];
        if ([rst isKindOfClass:[NSError class]]) {
            return [RACSignal error:rst];
        }
        if ([self respondsToSelector:@selector(parseResponseObject:)]) {
            rst = [self parseResponseObject:rsp];
        }
        if ([rst isKindOfClass:[NSError class]]) {
            return [RACSignal error:rst];
        }
        return [RACSignal return:rst];
    }] catch:^RACSignal *(NSError *error) {
        
        self.rsp_statusCode = error.code;
        self.rsp_error = error;
        
        DebugLog(@"〓〓〓〓〓〓〓〓 error:%@\n"
                 "method:%@ (id: %@)\n"
                 "code:  %ld", error.userInfo[NSLocalizedDescriptionKey], self.req_method, @(self.req_id), (long)error.code);
        
//        DebugLog(@"\n\n=====================Begin %@(id: %@) Error Detail==============================\n%@", self.req_method, @(self.req_id), error);
//        DebugLog(@"=====================Endof %@(id: %@) Error Detail==============================\n\n", self.req_method, @(self.req_id));
        
        if (gNetworkMgr.catchErrorHandler)
        {
            return gNetworkMgr.catchErrorHandler(self, error);
        }
        return [RACSignal error:error];
    }] replay];
    
    af_op.customObject = self;
    self.af_operation = af_op;
    _rac_curSignal = sig;
    
    return sig;
}


- (void)cancel
{
    [self.af_operation cancel];
}

+ (instancetype)operation
{
    return [[self alloc] init];
}

+ (void)cancelAllCurrentClassOpsInClient:(AFHTTPRequestOperationManager *)client
{
    NSArray *oplist = client.operationQueue.operations;
    for (NSOperation *op in oplist)
    {
        if ([op.customObject isMemberOfClass:[self class]] && !op.isCancelled)
        {
            [op cancel];
        }
    }
}

+ (NSArray *)allCurrentClassOpsInClient:(AFHTTPRequestOperationManager *)client
{
    NSArray *oplist = client.operationQueue.operations;
    return [oplist arrayByMapFilteringOperator:^id(NSOperation *obj) {
        
        return [obj.customObject isMemberOfClass:self] ? obj.customObject : nil;
    }];
}

#pragma mark - Parse
- (id)parseDefaultResponseObject:(id)obj
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        self.rsp_code = [[(NSDictionary *)obj objectForKey:@"rc"] integerValue];
        if (self.rsp_code != 0) {
            return [NSError errorWithDomain:@"请求失败" code:self.rsp_code userInfo:nil];
        }
    }
    return self;
}

#pragma mark - Simulation
- (RACSignal *)rac_simulateResponse
{
    return [[[[[RACSignal interval:self.simulateResponseDelay onScheduler:[RACScheduler scheduler]]
              take:1] flattenMap:^RACStream *(id value) {
        
        if ([self respondsToSelector:@selector(returnSimulateResponse)]) {
            id rsp = [self returnSimulateResponse];
            DebugLog(@"%@模拟\nmethod:%@ (id:%d)\nresponse:%@", kRspPrefix, self.req_method, self.req_id, rsp);
            if ([rsp isKindOfClass:[NSError class]]) {
                return [RACSignal error:rsp];
            }
            rsp = [self filterNSNullForParentObject:nil addNewObject:rsp withKey:nil fromOldObject:nil];
            id rstObj;
            if (rsp) {
                rstObj = [self parseDefaultResponseObject:rsp];
            }
            if ([rstObj isKindOfClass:[NSError class]]) {
                return [RACSignal error:rstObj];
            }
            if ([self respondsToSelector:@selector(parseResponseObject:)]) {
                rstObj = [self parseResponseObject:rsp];
            }
            if (rstObj) {
                return [RACSignal return:rstObj];
            }
        }
        return [RACSignal error:[NSError errorWithDomain:@"没有定义模拟数据" code:0 userInfo:nil]];
    }] doError:^(NSError *error) {
        
        DebugLog(@"%@模拟 method:%@ (id:%d):\n%@", kErrPrefix, self.req_method, self.req_id, error);
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

#pragma mark - Security
- (id)addSecurityParamsFrom:(id)oldParams
{
    id params;
    if ([oldParams isKindOfClass:[NSMutableArray class]] || [oldParams isKindOfClass:[NSMutableDictionary class]])
    {
        params = oldParams;
    }
    else if([oldParams isKindOfClass:[NSArray class]])
    {
        params = [NSMutableArray arrayWithArray:oldParams];
    }
    else if (oldParams)
    {
        params = [NSMutableArray arrayWithObject:oldParams];
    }
    else
    {
        params = [NSMutableDictionary dictionary];
    }
    
    // vid转化为 0000
    NSString *vid = [self addSafetyToLength:self.req_vid];
    if ([vid intValue] == 9999)
    {
        vid = @"0001";
    }
    NSString *skey = self.skey;

    if (![params isKindOfClass:[NSDictionary class]])
    {
        NSAssert(NO, @"params is not kind of NSDictionary class");
    }
    NSDictionary * paramsDict = (NSDictionary *)params;
    NSArray * paramsKeys = [[paramsDict keyEnumerator] allObjects];
    
    NSArray * sortedParamsKeys = [paramsKeys sortedArrayUsingSelector:@selector(compare:)];
    
    NSMutableString *rawvkey = [NSMutableString string];

    for (NSString * key in sortedParamsKeys)
    {
        [rawvkey safetyAppendString:[NSString stringWithFormat:@"%@=%@&",key,[paramsDict stringParamFroName:key]]];
    }
    if ([sortedParamsKeys count])
    {
        [rawvkey deleteCharactersInRange:NSMakeRange(rawvkey.length-1, 1)];
    }
    NSString * vkey = [[NSString stringWithFormat:@"%@%@",rawvkey,skey] md5];
    _vkey = vkey;
    
    NSMutableString *sign = [NSMutableString string];
    [sign safetyAppendString:_vkey];
    [sign safetyAppendString:self.token];
    
    if ([params isKindOfClass:[NSMutableDictionary class]])
    {
        [(NSMutableDictionary *)params safetySetObject:sign forKey:@"sign"];
    }
    else
    {
        [(NSMutableArray *)params safetyAddObject:sign];
    }
    return params;
}

#pragma mark - Getter
- (NSString *)token
{
    if (!_token)
    {
        _token = [NetworkManager sharedManager].token;
    }
    // 此行代码绝对不能动，用于判断第一次启动时，是否有token。有问题问JJC
    if (!_token) {
        _token = @"";
    }
    return _token;
}

- (NSString *)skey
{
    if (!_skey)
    {
        _skey = [NetworkManager sharedManager].skey;
    }
    return _skey;
}


#pragma mark - Utilities
- (NSString *)safetyString:(id)object
{
    if ([object isKindOfClass:[NSString class]])
    {
        return object;
    }
    else if ([object isKindOfClass:[NSNumber class]])
    {
        return [(NSNumber *)object stringValue];
    }
    return @"";
}

- (NSString *)addSafetyToLength:(int32_t)number
{
    NSNumber *num = @(number);
    NSString *numStr = [num stringValue];
    NSInteger count = numStr.length;
    
    NSMutableString *string = [NSMutableString string];
    for (int i=0;i<4 - count;i++)
    {
        [string appendString:@"0"];
    }
    [string appendString:numStr];
    
    NSString *str = (NSString *)string;
    return str;
}
- (id)filterNSNullForParentObject:(id)parentObj addNewObject:(id)newObj withKey:(id)key fromOldObject:(id)oldObj
{
    if ([newObj isKindOfClass:[NSArray class]])
    {
        newObj = [self filterNSNullForParentObject:[NSMutableArray array]
                                      addNewObject:[newObj objectEnumerator] withKey:nil fromOldObject:nil];
        parentObj =[self parentObject:parentObj addObject:newObj forKey:key];
    }
    else if ([newObj isKindOfClass:[NSDictionary class]])
    {
        newObj = [self filterNSNullForParentObject:[NSMutableDictionary dictionary]
                                      addNewObject:[newObj keyEnumerator] withKey:nil fromOldObject:newObj];
        parentObj = [self parentObject:parentObj addObject:newObj forKey:key];
    }
    else if ([newObj isKindOfClass:[NSEnumerator class]])
    {
        id nextObj = [newObj nextObject];
        if (!nextObj)
        {
            return parentObj;
        }
        if ([parentObj isKindOfClass:[NSMutableArray class]] && ![nextObj isKindOfClass:[NSNull class]])
        {
            nextObj = [self filterNSNullForParentObject:nil addNewObject:nextObj withKey:nil fromOldObject:nil];
            [parentObj addObject:nextObj];
            parentObj = [self filterNSNullForParentObject:parentObj addNewObject:newObj withKey:nil fromOldObject:nil];
        }
        if ([parentObj isKindOfClass:[NSMutableDictionary class]])
        {
            id curObj = [oldObj objectForKey:nextObj];
            if (![curObj isKindOfClass:[NSNull class]])
            {
                curObj = [self filterNSNullForParentObject:nil addNewObject:curObj withKey:nil fromOldObject:nil];
                [parentObj safetySetObject:curObj forKey:nextObj];
            }
            parentObj = [self filterNSNullForParentObject:parentObj addNewObject:newObj withKey:nil fromOldObject:oldObj];
        }
    }
    else
    {
        parentObj = [self parentObject:parentObj addObject:newObj forKey:key];
    }
    return parentObj;
}

- (id)parentObject:(id)parentObj addObject:(id)obj forKey:(id)key
{
    if ([parentObj isKindOfClass:[NSMutableArray class]])
    {
        [parentObj addObject:obj];
    }
    else if ([parentObj isKindOfClass:[NSMutableDictionary class]])
    {
        [parentObj setObject:obj forKey:key];
    }
    else if (!parentObj)
    {
        parentObj = obj;
    }
    return parentObj;
}


@end
