//
//  MutualInsScencePhotoVM.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsScencePhotoVM.h"
#import "GetCoorperationClaimConfigOp.h"
#import "PictureRecord.h"

@interface MutualInsScencePhotoVM ()

@property (nonatomic, strong) NSArray *sampleImgArr;

@property (nonatomic, strong) NSArray *maxPhotoNumArr;

@property (nonatomic, strong) NSArray *recordArray;

@end

@implementation MutualInsScencePhotoVM

-(void)dealloc
{
    DebugLog(@"MutualInsScencePhotoVM dealloc");
}

-(void)deleteAllInfo
{
    [self.recordArray makeObjectsPerformSelector:@selector(removeAllObjects)];
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

-(NSMutableArray *)recordArrayForIndex:(NSInteger)index
{
    return self.recordArray[index];
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


-(NSString *)URLStringForIndex:(NSInteger)index
{
    NSMutableArray *records = [self recordArrayForIndex:index];
    NSMutableArray *URLStr = [[NSMutableArray alloc]init];
    for (PictureRecord * rc in records)
    {
        [URLStr safetyAddObject:rc.url];
    }
    return [URLStr componentsJoinedByString:@","];
}

-(NSArray *)recordArray
{
    if (!_recordArray)
    {
        NSMutableArray *arr1 = [[NSMutableArray alloc]init];
        NSMutableArray *arr2 = [[NSMutableArray alloc]init];
        NSMutableArray *arr3 = [[NSMutableArray alloc]init];
        NSMutableArray *arr4 = [[NSMutableArray alloc]init];
        _recordArray = @[arr1,arr2,arr3,arr4];
    }
    return _recordArray;
}

@end
