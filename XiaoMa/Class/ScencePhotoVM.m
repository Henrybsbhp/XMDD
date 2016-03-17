//
//  ScencePhotoVM.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ScencePhotoVM.h"
#import "GetCoorperationClaimConfigOp.h"

@interface ScencePhotoVM ()

@property (nonatomic, strong) NSArray *sampleImgArr;

@property (nonatomic, strong) NSArray *maxPhotoNumArr;

@property (nonatomic, strong) NSArray *noticeArr;

@property (nonatomic, strong) NSArray *imgArr;

@property (nonatomic, strong) NSArray *urlArr;

@end

@implementation ScencePhotoVM

static ScencePhotoVM *scencePhotoVM;

-(void)getNoticeArr
{
    GetCoorperationClaimConfigOp *op = [[GetCoorperationClaimConfigOp alloc]init];
    [[op rac_postRequest]subscribeNext:^(GetCoorperationClaimConfigOp *op) {
        self.noticeArr = @[op.rsp_scenedesc,op.rsp_cardamagedesc,op.rsp_carinfodesc,op.rsp_idinfodesc];
    }];
}


+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        scencePhotoVM = [[ScencePhotoVM alloc] init];
    });
    return scencePhotoVM;
}

-(void)deleteAllInfo
{
    [self.imgArr makeObjectsPerformSelector:@selector(removeAllObjects)];
    [self.urlArr makeObjectsPerformSelector:@selector(removeAllObjects)];
}

#pragma mark ViewData

-(UIImage *)sampleImgForIndex:(NSInteger)index
{
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[self.sampleImgArr safetyObjectAtIndex:index]]];
    return img;
}

-(NSInteger)maxPhotoNumForIndex:(NSInteger)index
{
    NSNumber *maxPhoto = [self.maxPhotoNumArr safetyObjectAtIndex:index];
    return maxPhoto.integerValue;
}

-(NSString *)noticeForIndex:(NSInteger)index
{
    return [self.noticeArr safetyObjectAtIndex:index];
}

-(NSMutableArray *)imgArrForIndex:(NSInteger)index
{
    return self.imgArr[index];
}

-(NSMutableArray *)urlArrForIndex:(NSInteger)index
{
    return self.urlArr[index];
}

#pragma mark LazyLoad

-(NSArray *)sampleImgArr
{
    if (!_sampleImgArr)
    {
        _sampleImgArr = @[@"mutualIns_sceneContract",@"mutualIns_carLose",@"mutualIns_carInfo",@"mutualIns_drivingLicence"];
    }
    return _sampleImgArr;
}

-(NSArray *)maxPhotoNumArr
{
    if (!_maxPhotoNumArr)
    {
        _maxPhotoNumArr = @[@5,@5,@1,@2];
    }
    return _maxPhotoNumArr;
}

-(NSArray *)noticeArr
{
    if (!_noticeArr)
    {
        _noticeArr = [[NSMutableArray alloc]init];
        NSString *sceneContractStr = @"注：车牌号码要清晰，车辆接触状态要清晰可见，可从车头车尾进行多角度拍摄，拍摄照片越多越清晰，核定损失越准确(最多可拍摄5张)";
        NSString *carLoseStr = @"注：车辆受损区域照片要清晰可见，可从正面、侧面等进行多角度拍摄，拍摄照片越多越清晰，核定损失越准确(最多可拍摄5张)";
        NSString *carInfoStr = @"注：车辆车架号码照片要清晰可见，车架号数字与字母均可轻易识别，可近距离拍摄，请拍摄驾驶侧前挡风玻璃处车架号(最多可拍摄一张)";
        NSString *drivingLicenceStr = @"注：驾驶员的证件照要清晰，证件中包含的各类信息均可轻易识别，可近距离拍摄，可将驾驶证和行驶证分开拍摄，但二者缺一不可(最多可拍摄两张)";
        _noticeArr = @[sceneContractStr,carLoseStr,carInfoStr,drivingLicenceStr];
    }
    return _noticeArr;
}

-(NSArray *)imgArr
{
    if (!_imgArr)
    {
        NSMutableArray *arr1 = [[NSMutableArray alloc]init];
        NSMutableArray *arr2 = [[NSMutableArray alloc]init];
        NSMutableArray *arr3 = [[NSMutableArray alloc]init];
        NSMutableArray *arr4 = [[NSMutableArray alloc]init];
        _imgArr = @[arr1,arr2,arr3,arr4];
    }
    return _imgArr;
}

-(NSArray *)urlArr
{
    if (!_urlArr)
    {
        NSMutableArray *arr1 = [[NSMutableArray alloc]init];
        NSMutableArray *arr2 = [[NSMutableArray alloc]init];
        NSMutableArray *arr3 = [[NSMutableArray alloc]init];
        NSMutableArray *arr4 = [[NSMutableArray alloc]init];
        _urlArr = @[arr1,arr2,arr3,arr4];
    }
    return _urlArr;
}

@end
