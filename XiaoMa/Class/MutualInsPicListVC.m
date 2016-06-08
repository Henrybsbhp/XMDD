//
//  MutualInsPicListVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/5/30.
//  Copyright © 2016年 huika. All rights reserved.
//



#import "MutualInsPicListVC.h"
#import "GetPicListOp.h"
#import "HKImagePicker.h"
#import "UploadFileOp.h"
#import "PictureRecord.h"
#import "UpdateClaimPicOp.h"
#import "GetCoorperationClaimConfigOp.h"
#import "GetCooperationMyCarOp.h"
#import "MutualInsScencePageVC.h"
#import "MutualInsChooseCarVC.h"
#import "SDPhotoBrowser.h"
#import "GetSystemTimeOp.h"
#import "DAProgressOverlayView.h"
#import "ZFCDoubleBounceActivityIndicatorView.h"

#define kLength gAppMgr.deviceInfo.screenSize.width
#define kPhotoAddCount 5

@interface MutualInsPicListVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,SDPhotoBrowserDelegate>

// 页面组件
@property (strong, nonatomic) HKImagePicker *picker;
@property (nonatomic, strong) HKImageAlertVC *alert;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

// 底部上传按钮是否打开
@property (assign, nonatomic) BOOL firstswitch;
// 各个栏目能否继续上传图片，根据服务器下发的canaddflag“0101”来截取判断
@property (assign, nonatomic) BOOL sceneCanAdd;
@property (assign, nonatomic) BOOL damageCanAdd;
@property (assign, nonatomic) BOOL infoCanAdd;
@property (assign, nonatomic) BOOL licenceCanAdd;

// 原始数据
@property (strong, nonatomic) NSArray *scenePhotos;
@property (strong, nonatomic) NSArray *damagePhotos;
@property (strong, nonatomic) NSArray *infoPhotos;
@property (strong, nonatomic) NSArray *licencePhotos;

// 备份数据
@property (strong, nonatomic) NSMutableArray *scenePhotosCopy;
@property (strong, nonatomic) NSMutableArray *damagePhotosCopy;
@property (strong, nonatomic) NSMutableArray *infoPhotosCopy;
@property (strong, nonatomic) NSMutableArray *licencePhotosCopy;

// 需重拍数量
@property (assign, nonatomic) NSInteger sceneReupCount;
@property (assign, nonatomic) NSInteger damageReupCount;
@property (assign, nonatomic) NSInteger infoReupCount;
@property (assign, nonatomic) NSInteger licenceReupCount;

// SDPhotoBrowser所需要的中间变量
@property (strong, nonatomic) UIImage *img;
@property (strong, nonatomic) NSString *imgURL;


@end

@implementation MutualInsPicListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 初始化加载数据
    [self loadData];
    
    [self setupReupCount];
    
    [self setupBackBtn];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup

-(void)setupBackBtn
{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack)];
}

-(void)setupReupCount
{
    self.sceneReupCount = 0;
    self.damageReupCount = 0;
    self.infoReupCount = 0;
    self.licenceReupCount = 0;
}

#pragma mark - Network

-(void)loadData
{
    @weakify(self)
    GetPicListOp *op = [GetPicListOp operation];
    op.req_claimid = self.claimID;
    [[[op rac_postRequest] initially:^{
        @strongify(self)
        
        self.collectionView.hidden = YES;
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:CGPointMake(self.view.center.x, self.view.center.y *0.7)];
        
    }]subscribeNext:^(GetPicListOp *op) {
        @strongify(self)
        
        self.collectionView.hidden = YES;
        [self.view stopActivityAnimation];
        
        self.scenePhotos = op.rsp_localelist;
        self.infoPhotos = op.rsp_carinfolist;
        self.damagePhotos = op.rsp_carlosslist;
        self.licencePhotos = op.rsp_idphotolist;
        
        // 整理能否添加照片的标记
        [self seperateCanAddFlag:op.rsp_canaddflag AndFirstswitch:op.rsp_firstswitch];
        // 拷贝数据。进行对数据的备份
        [self convertData];
        // 检查是否有数据。通过判断显示默认页
        [self checkData];
        
    } error:^(NSError *error) {
        @strongify(self)
        
        [self.view stopActivityAnimation];
        self.collectionView.hidden = YES;
        [self.view showImageEmptyViewWithImageName:@"def_withoutValuationHistory" text:@"网络请求失败，请点击重试" tapBlock:^{
            [self loadData];
        }];
    }];
}

-(void)updateClaimPic
{
    NSNumber *checkFlag = [self checkPhotoNeedReupload];
    if (checkFlag.integerValue != 5)
    {
        NSString *errStr;
        switch (checkFlag.integerValue)
        {
            case 1:
                errStr = @"现场接触中仍有照片需要拍摄，请先拍摄后提交";
                break;
            case 2:
                errStr = @"车辆损失中仍有照片需要拍摄，请先拍摄后提交";
                break;
            case 3:
                errStr = @"车辆信息中仍有照片需要拍摄，请先拍摄后提交";
                break;
            case 4:
                errStr = @"证件照中仍有照片需要拍摄，请先拍摄后提交";
                break;
        }
        
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kDefTintColor clickBlock:nil];
        HKAlertVC *alert = [self alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:errStr ActionItems:@[cancel]];
        [alert show];
    }
    else if (![self checkPhotoIsUploading])
    {
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"知道了" color:kDefTintColor clickBlock:^(id alertVC) {
            [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0038"}];
        }];
        HKAlertVC *alert = [self alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"您仍有未重拍的照片，请先重拍后提交" ActionItems:@[cancel]];
        [alert show];
    }
    else if (self.scenePhotos.count == self.scenePhotosCopy.count &&
             self.damagePhotos.count == self.damagePhotosCopy.count &&
             self.infoPhotos.count == self.infoPhotosCopy.count &&
             self.licencePhotos.count == self.licencePhotosCopy.count )
    {
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"知道了" color:kDefTintColor clickBlock:nil];
        HKAlertVC *alert = [self alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"您有需补拍的照片，请先补拍后提交" ActionItems:@[cancel]];
        [alert show];
    }
    else
    {
        NSMutableArray *scenePhotos = [[NSMutableArray alloc]init];
        NSMutableArray *damagePhotos = [[NSMutableArray alloc]init];
        NSMutableArray *infoPhotos = [[NSMutableArray alloc]init];
        NSMutableArray *idPhotos = [[NSMutableArray alloc]init];
        
        for (id picRcd in self.scenePhotosCopy)
        {
            if ([picRcd isKindOfClass:[PictureRecord class]])
            {
                PictureRecord *picRecd = picRcd;
                [scenePhotos safetyAddObject:picRecd.url];
            }
        }
        for (id picRcd in self.damagePhotosCopy)
        {
            if ([picRcd isKindOfClass:[PictureRecord class]])
            {
                PictureRecord *picRecd = picRcd;
                [damagePhotos safetyAddObject:picRecd.url];
            }
        }
        for (id picRcd in self.infoPhotosCopy)
        {
            if ([picRcd isKindOfClass:[PictureRecord class]])
            {
                PictureRecord *picRecd = picRcd;
                [infoPhotos safetyAddObject:picRecd.url];
            }
        }
        for (id picRcd in self.licencePhotosCopy)
        {
            if ([picRcd isKindOfClass:[PictureRecord class]])
            {
                PictureRecord *picRecd = picRcd;
                [idPhotos safetyAddObject:picRecd.url];
            }
        }
        
        UpdateClaimPicOp *op = [UpdateClaimPicOp operation];
        op.req_claimid = self.claimID;
        
        op.req_localepic = [self stringForArray:scenePhotos];
        op.req_carlosspic = [self stringForArray:damagePhotos];
        op.req_carinfopic = [self stringForArray:infoPhotos];
        op.req_idphotopic = [self stringForArray:idPhotos];
        
        
        [[[op rac_postRequest]initially:^{
            [gToast showingWithText:@"上传照片中"];
        }]subscribeNext:^(id x) {
            
            [gToast showSuccess:@"上传照片完成"];
            
            NSDictionary *dic = @{@"claimID":self.claimID};
            [self postCustomNotificationName:kNotifyUpdateClaimList object:dic];
            
            CKAfter(0.5, ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
            
        } error:^(NSError *error) {
            NSString *errStr = error.domain.length == 0 ? @"上传照片失败" : error.domain;
            [gToast showMistake:errStr];
        }];
    }
}

- (NSString *)stringForArray:(NSMutableArray *)array
{
    NSString * value;
    NSString * aa = [array componentsJoinedByString:@"\",\""];
    if (array.count)
    {
        value = [NSString stringWithFormat:@"[\"%@\"]",aa];
    }
    else
    {
        value = @"[]";
    }
    return value;
}



-(RACSignal * )uploadFileWithPicRecord:(PictureRecord *)picrecord andIndex:(NSIndexPath *)indexPath
{
    RACSignal * signal;
    // 将图片的上传中属性设为YES。判断是否转菊花
    picrecord.isUploading = YES;
    picrecord.needReupload = NO;
    
    GetSystemTimeOp *sysTimeOp = [GetSystemTimeOp operation];
    signal = [[[[sysTimeOp rac_postRequest] flattenMap:^RACStream *(GetSystemTimeOp * timeOp) {
        
        return [[self addPrinting:timeOp.rsp_systime InPictureRecord:picrecord] flattenMap:^RACStream *(PictureRecord * picRecord) {
            
            //上传照片
            UploadFileOp *op = [UploadFileOp operation];
            op.req_fileType = UploadFileTypeMutualIns;
            op.req_fileExtType = @"jpg";
            [op setFileArray:[NSArray arrayWithObject:picRecord.image] withGetDataBlock:^NSData *(UIImage *img) {
                return UIImageJPEGRepresentation(img, 0.5);
            }];
            return [op rac_postRequest];
        }];
    }] doNext:^(UploadFileOp * uploadFileOp) {
        
        picrecord.isUploading = NO;
        picrecord.needReupload = NO;
        picrecord.url = uploadFileOp.rsp_urlArray.firstObject;
        
    }] catch:^RACSignal *(NSError *error) {
        
        picrecord.isUploading = NO;
        picrecord.needReupload = YES;
        
        return [RACSignal error:error];
    }];
    return signal;
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // 总共五部分
    return 4 + (self.firstswitch ? 1 : 0);
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    if (section == 0)
    {
        if (self.sceneCanAdd)
        {
            NSInteger maximum = self.scenePhotos.count + 6;
            count = MIN(maximum, self.scenePhotosCopy.count + 1 + (self.scenePhotosCopy.count - self.scenePhotos.count < 5 ? 1 : 0));
        }
        else
        {
            count = self.scenePhotos.count + 1;
        }
        
    }
    else if (section == 1)
    {
        if (self.damageCanAdd)
        {
            NSInteger maximum = self.damagePhotos.count + 6;
            count = MIN(maximum, self.damagePhotosCopy.count + 1 + (self.damagePhotosCopy.count - self.damagePhotos.count < 5 ? 1 : 0));
        }
        else
        {
            count = self.damagePhotos.count + 1;
        }
    }
    else if (section == 2)
    {
        if (self.infoCanAdd)
        {
            NSInteger maximum = self.infoPhotos.count + 6;
            count = MIN(maximum, self.infoPhotosCopy.count + 1 + (self.infoPhotosCopy.count - self.infoPhotos.count < 5 ? 1 : 0));
        }
        else
        {
            count = self.infoPhotos.count + 1;
        }
    }
    else if (section == 3)
    {
        if (self.licenceCanAdd)
        {
            NSInteger maximum = self.licencePhotos.count + 6;
            count = MIN(maximum, self.licencePhotosCopy.count + 1 + (self.licencePhotosCopy.count - self.licencePhotos.count < 5 ? 1 : 0));
        }
        else
        {
            count = self.licencePhotos.count + 1;
        }
    }
    else
    {
        count = 1;
    }
    
    return count;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *cell;
    // 照片cell
    if (indexPath.section != 4)
    {
        cell = [self imageViewCellForIndexPath:indexPath];
    }
    // 按钮cell
    else if (indexPath.section == 4)
    {
        cell = [self btnCellForIndexPath:indexPath];
    }
    return cell;
    
}

#pragma mark - UICollectionViewDelegateFlowLayout

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size;
    // 按钮cell 高度80
    if (indexPath.row == 0 && indexPath.section == 4)
    {
        size = CGSizeMake(kLength, 80);
    }
    // 标题cell 高度20
    else if (indexPath.row == 0 && indexPath.section != 4)
    {
        size = CGSizeMake(kLength, 20);
    }
    // 按钮cell 高度随屏幕大小改变
    else
    {
        size = CGSizeMake(ceil((kLength - 60) / 3), ceil((kLength - 60) / 3));
    }
    return size;
}

// 设置Footer高度
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (section == 4)
    {
        return CGSizeZero;
    }
    else if (section == 3)
    {
        return CGSizeMake(kLength, 2);
    }
    else
    {
        return CGSizeMake(kLength, 10);
    }
}

#pragma mark - UICollectionViewDelegate

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footerView" forIndexPath:indexPath];
    return headerView;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0)
    {
        return;
    }
    
    else
    {
        
        // 判断是否能添加照片。
        // 判断后台是否支持上传。判断是否已经添加。判断是否点击最后一个。
        if ([self canAddNewPhotoWithIndexPath:indexPath])
        {
            
            [self takePhotoWithIndexPath:indexPath];
            
        }
        else
        {
            // 点击看大图
            [self showHighQulifyPhotoWithIndexPath:indexPath];
            
        }
    }
}

#pragma mark - BtnCell

-(UICollectionViewCell *)btnCellForIndexPath:(NSIndexPath *)indexPath
{
    @weakify(self)
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"btnItem" forIndexPath:indexPath];
    UIButton *commitBtn = [cell viewWithTag:100];
    
    commitBtn.layer.cornerRadius = 5;
    commitBtn.layer.masksToBounds = YES;
    
    [[[commitBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
        @strongify(self)
        // 点击上传按钮。上传图片。
        
        [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0033"}];
        
        [self updateClaimPic];
    }];
    
    return cell;
}

#pragma mark - imgViewCell

-(UICollectionViewCell *)imageViewCellForIndexPath:(NSIndexPath *)indexPath
{
    @weakify(self)
    
    if (indexPath.row == 0)
    {
        UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"titleItem" forIndexPath:indexPath];
        
        UILabel *titleLabel = [cell viewWithTag:100];
        switch (indexPath.section)
        {
            case 0:
                titleLabel.text = @"现场接触";
                break;
            case 1:
                titleLabel.text = @"车辆损失";
                break;
            case 2:
                titleLabel.text = @"车辆信息";
                break;
            case 3:
                titleLabel.text = @"证件照";
                break;
        }
        return cell;
    }
    else
    {
        // 现场拍照
        if ([self canAddNewPhotoWithIndexPath:indexPath])
        {
            UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"addImgItem" forIndexPath:indexPath];
            return cell;
        }
        else
        {
            UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"imgViewItem" forIndexPath:indexPath];
            
            UIImageView *imageView = [cell viewWithTag:100];
            UIView *maskView = [cell viewWithTag:101];
            UILabel *noticeLabel = [cell viewWithTag:10101];
            UIButton *deleteBtn = [cell viewWithTag:102];
            UIView *overlayView = [cell viewWithTag:103];
            UIActivityIndicatorView *indicator = [cell viewWithTag:10301];
            
            
            [[[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
                @strongify(self)
                
                [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0032"}];
                
                HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
                HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确认" color:kDefTintColor clickBlock:^(id alertVC) {
                    [self deletePhotosWithItem:cell];
                }];
                HKAlertVC *alert = [self alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"请确认是否删除此照片？" ActionItems:@[cancel,confirm]];
                [alert show];
                
            }];
            
            
            id obj = [self getPictureRecordWithIndexPath:indexPath];
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                NSString *thumbnailURLlStr = [obj objectForKey:@"thumbnail"];
                
                /// @fq 使用缩略图
                [imageView setImageByUrl:thumbnailURLlStr withType:ImageURLTypeMedium defImage:@"mutualIns_excampleImg" errorImage:@"cm_defpic_fail"];
                
                deleteBtn.hidden = YES;
                
                NSNumber *isAgainUpload = [obj objectForKey:@"isagainupload"];
                maskView.hidden = isAgainUpload.integerValue == 0 ? YES : NO;
                noticeLabel.text = @"需重拍";
                
                overlayView.hidden = YES;
            }
            else if([obj isKindOfClass:[PictureRecord class]])
            {
                PictureRecord *picRcd = (PictureRecord *)obj;
                
                [[RACObserve(picRcd, needReupload) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSNumber * number) {
                    
                    BOOL flag = [number boolValue];
                    maskView.hidden = !flag;
                    noticeLabel.text = @"重新上传";
                }];
                
                [[RACObserve(picRcd, isUploading) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSNumber * number) {
                    
                    BOOL flag = [number boolValue];
                    overlayView.hidden = !flag;
                    deleteBtn.hidden = flag;
                    
                    if (flag)
                    {
                        [indicator startAnimating];
                    }
                    else
                    {
                        [indicator stopAnimating];
                    }
                }];
                
                [[RACObserve(picRcd, image) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                    
                    if (x && [x isKindOfClass:[UIImage class]])
                    {
                        imageView.image = picRcd.image;
                    }
                }];
            }
            return cell;
        }
    }
}

#pragma mark - Utility

-(BOOL)checkPhotoIsUploading
{
    for (PictureRecord *picRcd in self.scenePhotosCopy)
    {
        if ([picRcd isKindOfClass:[PictureRecord class]])
        {
            return !picRcd.isUploading;
        }
    }
    for (PictureRecord *picRcd in self.infoPhotosCopy)
    {
        if ([picRcd isKindOfClass:[PictureRecord class]])
        {
            return !picRcd.isUploading;
        }
    }
    for (PictureRecord *picRcd in self.damagePhotosCopy)
    {
        if ([picRcd isKindOfClass:[PictureRecord class]])
        {
            return !picRcd.isUploading;
        }
    }
    for (PictureRecord *picRcd in self.licencePhotosCopy)
    {
        if ([picRcd isKindOfClass:[PictureRecord class]])
        {
            return !picRcd.isUploading;
        }
    }
    return YES;
}

-(NSNumber *)checkPhotoNeedReupload
{
    if (self.scenePhotosCopy.count - self.scenePhotos.count < self.sceneReupCount)
    {
        return @(1);
    }
    else if (self.damagePhotosCopy.count - self.damagePhotos.count < self.damageReupCount)
    {
        return @(2);
    }
    else if (self.infoPhotosCopy.count - self.infoPhotos.count < self.infoReupCount)
    {
        return @(3);
    }
    else if (self.licencePhotosCopy.count - self.licencePhotos.count < self.licenceReupCount)
    {
        return @(4);
    }
    else
    {
        return @(5);
    }
}

-(HKImageAlertVC *)alertWithTopTitle:(NSString *)topTitle ImageName:(NSString *)imageName Message:(NSString *)message ActionItems:(NSArray *)actionItems
{
    if (!_alert)
    {
        _alert = [[HKImageAlertVC alloc]init];
    }
    _alert.topTitle = topTitle;
    _alert.imageName = imageName;
    _alert.message = message;
    _alert.actionItems = actionItems;
    return _alert;
}

-(PictureRecord *)getPictureRecordWithIndexPath:(NSIndexPath *)indexPath
{
    PictureRecord *picRcd;
    switch (indexPath.section)
    {
        case 0:
            picRcd = [self.scenePhotosCopy safetyObjectAtIndex:indexPath.row - 1];
            break;
        case 1:
            picRcd = [self.damagePhotosCopy safetyObjectAtIndex:indexPath.row - 1];
            break;
        case 2:
            picRcd = [self.infoPhotosCopy safetyObjectAtIndex:indexPath.row - 1];
            break;
        case 3:
            picRcd = [self.licencePhotosCopy safetyObjectAtIndex:indexPath.row - 1];
            break;
    }
    return picRcd;
}

-(void)addPictureRecord:(PictureRecord *)picRcd withIndex:(NSIndexPath *)indexPath
{
    // 防止上传照片时重复添加
    if (!picRcd.needReupload)
    {
        // 每添加一张照片判断照片所属类型
        switch (indexPath.section)
        {
            case 0:
                [self.scenePhotosCopy addObject:picRcd];
                break;
            case 1:
                [self.damagePhotosCopy addObject:picRcd];
                break;
            case 2:
                [self.infoPhotosCopy addObject:picRcd];
                break;
            case 3:
                [self.licencePhotosCopy addObject:picRcd];
                break;
        }
    }
}

- (BOOL)isPhotoFullWithPath:(NSIndexPath *)indexPath
{
    NSInteger  reminder = 0;
    switch (indexPath.section)
    {
        case 0:
            
            reminder = self.scenePhotosCopy.count - self.scenePhotos.count;
            break;
        case 1:
            reminder = self.damagePhotosCopy.count - self.damagePhotos.count;
            break;
        case 2:
            reminder = self.infoPhotosCopy.count - self.infoPhotos.count;
            break;
        case 3:
            reminder = self.licencePhotosCopy.count - self.licencePhotos.count;
            break;
    }
    return reminder >= 5 ? YES : NO;
}

-(void)deletePhotosWithItem:(UICollectionViewCell *)cell
{
    NSInteger total = 0;
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    switch (indexPath.section)
    {
        case 0:
            
            [self.scenePhotosCopy safetyRemoveObjectAtIndex:indexPath.row -1];
            total = self.scenePhotos.count + 5 + 1;
            break;
        case 1:
            [self.damagePhotosCopy safetyRemoveObjectAtIndex:indexPath.row -1];
            total = self.damagePhotos.count + 5 + 1;
            break;
        case 2:
            [self.infoPhotosCopy safetyRemoveObjectAtIndex:indexPath.row -1];
            total = self.infoPhotos.count + 5 + 1;
            break;
        case 3:
            [self.licencePhotosCopy safetyRemoveObjectAtIndex:indexPath.row -1];
            total = self.licencePhotos.count + 5 + 1;
            break;
    }
    
    NSInteger count = [self.collectionView numberOfItemsInSection:indexPath.section];
    
    if (count != total)
    {
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    }
    else
    {
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
    }
}

-(void)showHighQulifyPhotoWithIndexPath:(NSIndexPath *)indexPath
{
    id picRcd;
    
    switch (indexPath.section)
    {
        case 0:
            picRcd = [self.scenePhotosCopy safetyObjectAtIndex:indexPath.row -1];
            break;
        case 1:
            picRcd = [self.damagePhotosCopy safetyObjectAtIndex:indexPath.row -1];
            break;
        case 2:
            picRcd = [self.infoPhotosCopy safetyObjectAtIndex:indexPath.row -1];
            break;
        case 3:
            picRcd = [self.licencePhotosCopy safetyObjectAtIndex:indexPath.row - 1];
            break;
    }
    
    if ([picRcd isKindOfClass:[NSDictionary class]])
    {
        
        [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0030"}];
        
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        UIImageView *imgView = [cell viewWithTag:100];
        self.img = imgView.image;
        self.imgURL = picRcd[@"picurl"];
        
        SDPhotoBrowser *photoBrowser = [SDPhotoBrowser new];
        photoBrowser.delegate = self;
        photoBrowser.imageCount = 1;
        photoBrowser.sourceImagesContainerView = cell;
        
        [photoBrowser show];
    }
    else
    {
        PictureRecord *picRecd = picRcd;
        if(!picRecd.needReupload)
        {
            
                [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0030"}];
            
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            UIImageView *imgView = [cell viewWithTag:100];
            
            self.img = imgView.image;
            self.imgURL = picRecd.url;
            
            SDPhotoBrowser *photoBrowser = [SDPhotoBrowser new];
            photoBrowser.delegate = self;
            photoBrowser.imageCount = 1;
            photoBrowser.sourceImagesContainerView = cell;
            
            [photoBrowser show];
        }
        else
        {
            [[self uploadFileWithPicRecord:picRecd andIndex:indexPath] subscribeNext:^(id x) {
                
            } error:^(NSError *error) {
                
            }];
        }
    }
}

-(void)takePhotoWithIndexPath:(NSIndexPath *)indexPath
{
    
    [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0031"}];
    __block PictureRecord *picRcd = [[PictureRecord alloc] init];
    
#if !TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    
    [[[self.picker rac_pickImageInTargetVC:self inView:self.navigationController.view] flattenMap:^RACStream *(UIImage *img) {
        
        picRcd.image = img;
        [self addPictureRecord:picRcd withIndex:indexPath];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
        
        return [self uploadFileWithPicRecord:picRcd andIndex:indexPath];
    }]subscribeNext:^(PictureRecord *picRcd) {
        
        // 上传图片
        
    }error:^(NSError *error) {
        
        PictureRecord *picRcd = [self getPictureRecordWithIndexPath:indexPath];
        picRcd.isUploading = NO;
        picRcd.needReupload = YES;
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
        [gToast showMistake:error.domain.length != 0 ? error.domain : @"网络连接失败，请检查你的网络设置"];
    }];
    
#else
    
    [[[self.picker rac_pickPhotoTargetVC:self inView:self.navigationController.view] flattenMap:^RACStream *(UIImage *img) {
        
        picRcd.isUploading = YES;
        picRcd.image = img;
        [self addPictureRecord:picRcd withIndex:indexPath];
        
        if ([self isPhotoFullWithPath:indexPath])
        {
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
        else
        {
            [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
        }
        
        
        return [self uploadFileWithPicRecord:picRcd andIndex:indexPath];
    }] subscribeNext:^(id x) {
        
    } error:^(NSError *error) {
        
    }];
#endif
}

-(void)checkData
{
    if (self.scenePhotos.count == 0 &&
        self.infoPhotos.count == 0 &&
        self.damagePhotos.count == 0 &&
        self.licencePhotos.count == 0 )
    {
        self.collectionView.hidden = YES;
        // 显示缺省页。并对缺省页进行配置
        [self showDefaultView];
    }
    else
    {
        for (NSDictionary *dic in self.scenePhotos)
        {
            NSNumber *isAgainUpload = [dic objectForKey:@"isagainupload"];
            if (isAgainUpload.integerValue == 1)
            {
                self.sceneReupCount ++;
            }
        }
        for (NSDictionary *dic in self.infoPhotos)
        {
            NSNumber *isAgainUpload = [dic objectForKey:@"isagainupload"];
            if (isAgainUpload.integerValue == 1)
            {
                self.infoReupCount ++;
            }
        }
        for (NSDictionary *dic in self.damagePhotos)
        {
            NSNumber *isAgainUpload = [dic objectForKey:@"isagainupload"];
            if (isAgainUpload.integerValue == 1)
            {
                self.damageReupCount ++;
            }
        }
        for (NSDictionary *dic in self.licencePhotos)
        {
            NSNumber *isAgainUpload = [dic objectForKey:@"isagainupload"];
            if (isAgainUpload.integerValue == 1)
            {
                self.licenceReupCount ++;
            }
        }
        
        self.collectionView.hidden = NO;
        [self.view hideDefaultEmptyView];
        [self.collectionView reloadData];
    }
}

-(void)convertData
{
    self.scenePhotosCopy = [self.scenePhotos mutableCopy];
    self.infoPhotosCopy = [self.infoPhotos mutableCopy];
    self.damagePhotosCopy = [self.damagePhotos mutableCopy];
    self.licencePhotosCopy = [self.licencePhotos mutableCopy];
}

-(BOOL)canAddNewPhotoWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        // 判断后台是否支持上传。判断是否已经添加。判断是否点击最后一个。
        
        if (!self.sceneCanAdd ||
            (self.scenePhotosCopy.count - self.scenePhotos.count) > 4 ||
            indexPath.row != self.scenePhotosCopy.count + 1)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else if (indexPath.section == 1)
    {
        if (!self.damageCanAdd ||
            (self.damagePhotosCopy.count - self.damagePhotos.count) > 4 ||
            indexPath.row != self.damagePhotosCopy.count + 1)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else if (indexPath.section == 2)
    {
        
        if (!self.infoCanAdd ||
            (self.infoPhotosCopy.count - self.infoPhotos.count) > 4 ||
            indexPath.row != self.infoPhotosCopy.count + 1)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else
    {
        
        if (!self.licenceCanAdd ||
            (self.licencePhotosCopy.count - self.licencePhotos.count) > 4 ||
            indexPath.row != self.licencePhotosCopy.count + 1)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
}

-(void)seperateCanAddFlag:(NSString *)canAddFlag AndFirstswitch:(NSNumber *)firstswitch
{
    NSString *sceneFlag = [canAddFlag substringFromIndex:0 toIndex:1];
    NSString *damageFlag = [canAddFlag substringFromIndex:1 toIndex:2];
    NSString *infoFlag = [canAddFlag substringFromIndex:2 toIndex:3];
    NSString *licenceFlag = [canAddFlag substringFromIndex:3 toIndex:4];
    
    self.sceneCanAdd = sceneFlag.integerValue == 1 ? YES : NO;
    self.damageCanAdd = damageFlag.integerValue == 1 ? YES : NO;
    self.infoCanAdd = infoFlag.integerValue == 1 ? YES : NO;
    self.licenceCanAdd = licenceFlag.integerValue == 1 ? YES : NO;
    
    NSNumber *firstswitchNum = firstswitch;
    self.firstswitch = firstswitchNum.integerValue == 0 ? NO : YES;
}

-(void)showDefaultView
{
    [self.view showImageEmptyViewWithImageName:@"def_withoutValuationHistory" text:@"暂无任何照片"];
    if (self.firstswitch)
    {
        // 配置按钮
        UIButton *takePhotoBtn = [[UIButton alloc]init];
        takePhotoBtn.backgroundColor = HEXCOLOR(@"#18d06a");
        [takePhotoBtn setTitle:@"拍摄照片上传" forState:UIControlStateNormal];
        [takePhotoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        takePhotoBtn.layer.cornerRadius = 5;
        takePhotoBtn.layer.masksToBounds = YES;
        
        [self.view addSubview:takePhotoBtn];
        [self.view bringSubviewToFront:takePhotoBtn];
        
        [takePhotoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-15);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.height.mas_equalTo(50);
        }];
        [[takePhotoBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
            
            // 跳转至拍照页面
            [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0039"}];
            [self getScencePageData];
            
        }];
    }
}

-(RACSignal *)addPrinting:(NSString *)time InPictureRecord:(PictureRecord *)picRcd
{
    RACSubject *subject = [RACSubject subject];
    CKAsyncHighQueue(^{
        
        UIImage *img = picRcd.image;
        
        UIGraphicsBeginImageContext(img.size);
        
        [img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[NSFontAttributeName] = [UIFont systemFontOfSize:60];
        attributes[NSForegroundColorAttributeName] = [UIColor colorWithRed:100 green:100 blue:100 alpha:0.8];
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.alignment = NSTextAlignmentRight;
        attributes[NSParagraphStyleAttributeName] = paragraph;
        CGSize textSize = [time boundingRectWithSize:CGSizeMake(img.size.width, img.size.height * 0.5) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
        CGFloat x = img.size.width - textSize.width;
        CGFloat y = img.size.height - textSize.height;
        [time drawInRect:CGRectMake(x, y, textSize.width, textSize.height) withAttributes:attributes];
        UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
        
        picRcd.image = newImg;
        
        UIGraphicsEndImageContext();
        
        CKAsyncMainQueue(^{
            [subject sendNext:picRcd];
            [subject sendCompleted];
        });
    });
    return subject;
}

#pragma mark - LazyLoad

-(HKImagePicker *)picker
{
    if (!_picker)
    {
        _picker = [HKImagePicker imagePicker];
        _picker.compressedSize = CGSizeMake(1024, 1024);
    }
    return _picker;
}

#pragma mark - Action

-(void)actionGotoMutualInsScencePageVCWithReport:(NSDictionary *)report andNotice:(NSArray *)notice
{
    MutualInsScencePageVC *scencePageVC = [UIStoryboard vcWithId:@"MutualInsScencePageVC" inStoryboard:@"MutualInsClaims"];
    scencePageVC.noticeArr = notice;
    scencePageVC.claimid = report[@"claimid"];
    [self.navigationController pushViewController:scencePageVC animated:YES];
}

-(void)actionBack
{
    
    [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0029"}];
    
    if (self.scenePhotosCopy.count - self.scenePhotos.count > 0 ||
        self.damagePhotosCopy.count - self.damagePhotos.count > 0 ||
        self.infoPhotosCopy.count - self.infoPhotos.count > 0 ||
        self.licencePhotosCopy.count - self.licencePhotos.count > 0)
    {
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:^(id alertVC) {
            [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0034"}];
        }];
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"去意已决" color:kDefTintColor clickBlock:^(id alertVC) {
            [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0035"}];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        HKAlertVC *alert = [self alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"请确认是否放弃重新拍摄的照片并且返回？" ActionItems:@[cancel,confirm]];
        [alert show];
    }
    else if ((self.scenePhotos.count == 0 &&
              self.damagePhotos.count == 0 &&
              self.infoPhotos.count == 0 &&
              self.licencePhotos.count == 0) ||
             (!self.sceneCanAdd &&
              !self.damageCanAdd &&
              !self.infoCanAdd &&
              !self.licenceCanAdd))
    {
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    else if (self.scenePhotosCopy.count - self.scenePhotos.count == 0 &&
             self.damagePhotosCopy.count - self.damagePhotos.count == 0 &&
             self.infoPhotosCopy.count - self.infoPhotos.count == 0 &&
             self.licencePhotosCopy.count - self.licencePhotos.count == 0)
    {
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:^(id alertVC) {
            [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0036"}];
        }];
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"去意已决" color:kDefTintColor clickBlock:^(id alertVC) {
            [MobClick event:@"xiaomahuzhu" attributes:@{@"key":@"woyaopei",@"values":@"woyaopei0037"}];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        HKAlertVC *alert = [self alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"您仍有照片需要拍摄上传，请确认是否返回？" ActionItems:@[cancel,confirm]];
        [alert show];
    }
}


#pragma mark - SDPhotoBrowserDelegate

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    return self.img;
}

- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    return [NSURL URLWithString:self.imgURL];
}

#pragma mark - GotoScenePhotoVC

-(RACSignal *)getScencePageNoticeArr
{
    GetCoorperationClaimConfigOp *op = [GetCoorperationClaimConfigOp operation];
    return [op rac_postRequest];
}

-(RACSignal *)getScencePageCarListData
{
    GetCooperationMyCarOp *op = [GetCooperationMyCarOp operation];
    return [op rac_postRequest];
}

-(void)getScencePageData
{
    @weakify(self)
    RACSignal *noticeSignal = [self getScencePageNoticeArr];
    RACSignal *carListSignal = [self getScencePageCarListData];
    RACSignal *combineSignal = [noticeSignal combineLatestWith:carListSignal];
    [[combineSignal initially:^{
        
        [gToast showingWithText:@"数据加载中"];
        
    }]subscribeNext:^(RACTuple *arr) {
        
        @strongify(self)
        
        [gToast dismiss];
        
        GetCoorperationClaimConfigOp *claimConfigOp = arr.first;
        GetCooperationMyCarOp *carOp = arr.second;
        
        NSArray *noticeArr = @[claimConfigOp.rsp_scenedesc,claimConfigOp.rsp_cardamagedesc,claimConfigOp.rsp_carinfodesc,claimConfigOp.rsp_idinfodesc];
        
        [self actionGotoMutualInsScencePageVCWithReport:carOp.rsp_reports.firstObject andNotice:noticeArr];
        
    } error:^(NSError *error) {
        
        [gToast showMistake:error.domain];
        
    }];
}

@end
