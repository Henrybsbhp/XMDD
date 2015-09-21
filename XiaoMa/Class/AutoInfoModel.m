//
//  AutoInfoModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "AutoInfoModel.h"
#import "GetAutomobileBrandOp.h"
#import "GetAutomobileModelOp.h"

#define kAutoBrandTimetag       @"com.xmdd.auto.brand.timetag"

@implementation AutoInfoModel

- (NSFetchedResultsController *)createAutoBrandFetchCtrl
{
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"AutoBrand"];
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:YES];
    NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"brandid" ascending:YES];
    req.sortDescriptors = @[sort1,sort2];
    req.shouldRefreshRefetchedObjects = NO;
    NSFetchedResultsController *ctrl = [[NSFetchedResultsController alloc] initWithFetchRequest:req
                                                                           managedObjectContext:gAppMgr.defDataMgr.managedObjectContext sectionNameKeyPath:@"tag"
                                                                                      cacheName:nil];
    return ctrl;
}
- (RACSignal *)rac_updateAutoBrand
{
    GetAutomobileBrandOp *op = [GetAutomobileBrandOp new];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSNumber *timetag = [def objectForKey:kAutoBrandTimetag];
    op.req_timetag = timetag ? timetag : @(0);
    return [[op rac_postRequest] map:^id(GetAutomobileBrandOp *rspOp) {
        __block NSNumber *maxTimetag = rspOp.req_timetag;
        NSArray *brands = [rspOp.rsp_brands arrayByMappingOperator:^id(NSDictionary *dict) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"brandid = %@", dict[@"bid"]];
            AutoBrand *brand = [gAppMgr.defDataMgr insertOrReplaceObjectForEntityName:@"AutoBrand" filterPredicate:predicate];
            [brand resetWithJSONResponse:dict];
            if (maxTimetag < brand.timetag) {
                maxTimetag = brand.timetag;
            }
            return brand;
        }];
        [gAppMgr.defDataMgr saveContext];
        [def setObject:maxTimetag forKey:kAutoBrandTimetag];
        return brands;
    }];
}


@end
