//
//  MutualInsPicListVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/5/30.
//  Copyright © 2016年 huika. All rights reserved.
//

#define kLength self.view.frame.size.width

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

@interface MutualInsPicListVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,SDPhotoBrowserDelegate>

// 页面组件
@property (strong, nonatomic) HKImagePicker *picker;
@property (nonatomic, strong) HKImageAlertVC *alert;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

// 各个子模块能否添加标记
@property (assign, nonatomic) BOOL firstswitch;
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

// 水印
@property (strong, nonatomic) NSString *waterMarkStr;


@end

@implementation MutualInsPicListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化加载数据
    [self loadData];
    
    [self setupReupCount];
    
    [self setupBackBtn];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup

-(void)setupBackBtn
{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(back)];
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
    
    if ([self checkPhotoNeedReupload])
    {
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kDefTintColor clickBlock:nil];
        HKAlertVC *alert = [self alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"您仍有未重拍的照片，请先重拍后提交" ActionItems:@[cancel]];
        [alert show];
    }
    else
    {
        NSMutableArray *scenePhotos = [[NSMutableArray alloc]init];
        NSMutableArray *damagePhotos = [[NSMutableArray alloc]init];
        NSMutableArray *infoPhotos = [[NSMutableArray alloc]init];
        NSMutableArray *idPhotos = [[NSMutableArray alloc]init];
        
        for (PictureRecord *picRcd in self.scenePhotosCopy)
        {
            [scenePhotos safetyAddObject:picRcd.url];
        }
        for (PictureRecord *picRcd in self.damagePhotosCopy)
        {
            [damagePhotos safetyAddObject:picRcd.url];
        }
        for (PictureRecord *picRcd in self.infoPhotosCopy)
        {
            [infoPhotos safetyAddObject:picRcd.url];
        }
        for (PictureRecord *picRcd in self.licencePhotosCopy)
        {
            [idPhotos safetyAddObject:picRcd.url];
        }
        
        UpdateClaimPicOp *op = [UpdateClaimPicOp operation];
        op.req_claimid = self.claimID;
        op.req_localepic = scenePhotos;
        op.req_carlosspic = damagePhotos;
        op.req_carinfopic = infoPhotos;
        op.req_idphotopic = idPhotos;
        
        [[[op rac_postRequest]initially:^{
            [gToast showingWithText:@"上传照片中"];
        }]subscribeNext:^(id x) {
            
            [gToast showSuccess:@"上传照片完成"];
            
            NSDictionary *dic = @{@"claimID":self.claimID};
            [self postCustomNotificationName:kUpdateClaimPhotosSuccess object:dic];
            
            CKAfter(0.5, ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
            
            
        } error:^(NSError *error) {
            [gToast showError:@"上传照片失败"];
        }];
    }
}



-(void)uploadFileWithPicRecord:(PictureRecord *)picrecord andIndex:(NSIndexPath *)indexPath
{
    
    // 将图片的上传中属性设为YES。判断是否转菊花
    picrecord.isUploading = YES;
    picrecord.needReupload = NO;
    
    //上传照片
    UploadFileOp *op = [UploadFileOp operation];
    op.req_fileType = UploadFileTypeMutualIns;
    op.req_fileExtType = @"jpg";
    [op setFileArray:[NSArray arrayWithObject:picrecord.image] withGetDataBlock:^NSData *(UIImage *img) {
        return UIImageJPEGRepresentation(img, 0.5);
    }];
    
    [[[op rac_postRequest]initially:^{
        
        // 通知collectionview显示图片。并开始转菊花。
        [self.collectionView reloadData];
    }]subscribeNext:^(UploadFileOp *op) {
        // 通知系统停止转菊花
        picrecord.isUploading = NO;
        picrecord.needReupload = NO;
        picrecord.url = op.rsp_urlArray.firstObject;
        [self.collectionView reloadData];
        
    } error:^(NSError *error) {
        // 通知系统停止转菊花。并设置需要重新上传属性。通过此属性判断是否显示遮罩层。
        picrecord.isUploading = NO;
        picrecord.needReupload = YES;
        [self.collectionView reloadData];
        
    }];
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
    
    switch (section)
    {
        case 0:
            // 可能会有点难读。主要是为了限制只能重新拍五张照片
            count = MIN(self.scenePhotos.count + 1 + 5, self.scenePhotosCopy.count + 1 + (self.scenePhotosCopy.count - self.scenePhotos.count < 5 ? 1 : 0));
            break;
        case 1:
            count = MIN(self.damagePhotos.count + 1 + 5, self.damagePhotosCopy.count + 1 + (self.damagePhotosCopy.count - self.damagePhotos.count < 5 ? 1 : 0));
            break;
        case 2:
            count = MIN(self.infoPhotos.count + 1 + 5, self.infoPhotosCopy.count + 1 + (self.infoPhotosCopy.count - self.infoPhotos.count < 5 ? 1 : 0));
            break;
        case 3:
            count = MIN(self.licencePhotos.count + 1 + 5, self.licencePhotosCopy.count + 1 + (self.licencePhotosCopy.count - self.licencePhotos.count < 5 ? 1 : 0));
            break;
        default:
            count = 1;
            break;
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
        size = CGSizeMake((kLength - 60) / 3, (kLength - 60) / 3);
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
        [self updateClaimPic];
    }];
    
    return cell;
}

#pragma mark - imgViewCell

-(UICollectionViewCell *)imageViewCellForIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    
    // 现场拍照
    if (indexPath.section == 0)
    {
        cell = [self scenePhotoCellForIndexPath:indexPath];
    }
    // 车辆损失
    else if(indexPath.section == 1)
    {
        cell = [self damagePhotoCellForIndexPath:indexPath];
    }
    // 车辆信息
    else if (indexPath.section == 2)
    {
        cell = [self infoPhotoCellForIndexPath:indexPath];
    }
    // 证件照
    else if (indexPath.section == 3)
    {
        cell = [self licencePhotoCellForIndexPath:indexPath];
    }
    
    return cell;
}

-(UICollectionViewCell *)scenePhotoCellForIndexPath:(NSIndexPath *)indexPath
{
    @weakify(self)
    UICollectionViewCell *cell;
    if (indexPath.row == 0)
    {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"titleItem" forIndexPath:indexPath];
        
        UILabel *titleLabel = [cell viewWithTag:100];
        titleLabel.text = @"现场接触";
        
    }
    else
    {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"imgViewItem" forIndexPath:indexPath];
        
        UIImageView *imageView = [cell viewWithTag:100];
        UIView *maskView = [cell viewWithTag:101];
        UILabel *noticeLabel = [cell viewWithTag:10101];
        UIButton *deleteBtn = [cell viewWithTag:102];
        UIView *overlayView = [cell viewWithTag:103];
        UIActivityIndicatorView *indicator = [cell viewWithTag:10301];
        
        
        [[[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
            @strongify(self)
            
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
            HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确认" color:kDefTintColor clickBlock:^(id alertVC) {
                [self deletePhotosWithItem:cell];
            }];
            HKAlertVC *alert = [self alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"请确认是否删除此照片？" ActionItems:@[cancel,confirm]];
            [alert show];
            
        }];
        
        
        id obj = [self.scenePhotosCopy safetyObjectAtIndex:indexPath.row - 1];
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            NSString *urlStr = [obj objectForKey:@"picurl"];
            
            [imageView setImageByUrl:urlStr withType:ImageURLTypeMedium defImage:@"mutualIns_excampleImg" errorImage:@"cm_defpic_fail"];
            
            deleteBtn.hidden = YES;
            
            NSNumber *isAgainUpload = [obj objectForKey:@"isagainupload"];
            maskView.hidden = isAgainUpload.integerValue == 0 ? YES : NO;
            noticeLabel.text = @"需重拍";
            
            overlayView.hidden = YES;
        }
        else if([obj isKindOfClass:[PictureRecord class]])
        {
            PictureRecord *picRcd = (PictureRecord *)obj;
            
            imageView.image = picRcd.image;
            
            if (picRcd.needReupload)
            {
                maskView.hidden = NO;
                noticeLabel.text = @"请重新上传";
            }
            else
            {
                maskView.hidden = YES;
            }
            
            if (picRcd.isUploading)
            {
                overlayView.hidden = NO;
                deleteBtn.hidden = YES;
                [indicator startAnimating];
            }
            else
            {
                deleteBtn.hidden = NO;
                overlayView.hidden = YES;
            }
        }
        
        if (self.sceneCanAdd && indexPath.row == self.scenePhotosCopy.count + 1)
        {
            cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"addImgItem" forIndexPath:indexPath];
        }
        
    }
    return cell;
}

-(UICollectionViewCell *)damagePhotoCellForIndexPath:(NSIndexPath *)indexPath
{
    @weakify(self)
    UICollectionViewCell *cell;
    if (indexPath.row == 0)
    {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"titleItem" forIndexPath:indexPath];
        
        UILabel *titleLabel = [cell viewWithTag:100];
        
        titleLabel.text = @"车辆损失";
    }
    else
    {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"imgViewItem" forIndexPath:indexPath];
        
        UIImageView *imageView = [cell viewWithTag:100];
        UIView *maskView = [cell viewWithTag:101];
        UILabel *noticeLabel = [cell viewWithTag:10101];
        UIButton *deleteBtn = [cell viewWithTag:102];
        UIView *overlayView = [cell viewWithTag:103];
        UIActivityIndicatorView *indicator = [cell viewWithTag:10301];
        
        
        [[[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
            @strongify(self)
            
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
            HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确认" color:kDefTintColor clickBlock:^(id alertVC) {
                [self deletePhotosWithItem:cell];
            }];
            HKAlertVC *alert = [self alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"请确认是否删除此照片？" ActionItems:@[cancel,confirm]];
            [alert show];
            
        }];
        
        
        id obj = [self.damagePhotosCopy safetyObjectAtIndex:indexPath.row - 1];
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            NSString *urlStr = [obj objectForKey:@"picurl"];
            
            [imageView setImageByUrl:urlStr withType:ImageURLTypeMedium defImage:@"mutualIns_excampleImg" errorImage:@"cm_defpic_fail"];
            
            deleteBtn.hidden = YES;
            
            NSNumber *isAgainUpload = [obj objectForKey:@"isagainupload"];
            maskView.hidden = isAgainUpload.integerValue == 0 ? YES : NO;
            noticeLabel.text = @"需重拍";
            
            overlayView.hidden = YES;
        }
        else if([obj isKindOfClass:[PictureRecord class]])
        {
            PictureRecord *picRcd = (PictureRecord *)obj;
            
            imageView.image = picRcd.image;
            
            if (picRcd.needReupload)
            {
                maskView.hidden = NO;
                noticeLabel.text = @"请重新上传";
            }
            else
            {
                maskView.hidden = YES;
            }
            
            if (picRcd.isUploading)
            {
                overlayView.hidden = NO;
                [indicator startAnimating];
                deleteBtn.hidden = YES;
            }
            else
            {
                deleteBtn.hidden = NO;
                overlayView.hidden = YES;
            }
        }
        if (self.damageCanAdd && indexPath.row == self.damagePhotosCopy.count + 1)
        {
            cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"addImgItem" forIndexPath:indexPath];
        }
        
    }
    return cell;
}

-(UICollectionViewCell *)infoPhotoCellForIndexPath:(NSIndexPath *)indexPath
{
    @weakify(self)
    UICollectionViewCell *cell;
    if (indexPath.row == 0)
    {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"titleItem" forIndexPath:indexPath];
        
        UILabel *titleLabel = [cell viewWithTag:100];
        
        titleLabel.text = @"车辆信息";
    }
    else
    {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"imgViewItem" forIndexPath:indexPath];
        
        UIImageView *imageView = [cell viewWithTag:100];
        UIView *maskView = [cell viewWithTag:101];
        UILabel *noticeLabel = [cell viewWithTag:10101];
        UIButton *deleteBtn = [cell viewWithTag:102];
        UIView *overlayView = [cell viewWithTag:103];
        UIActivityIndicatorView *indicator = [cell viewWithTag:10301];
        
        
        [[[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
            @strongify(self)
            
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
            HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确认" color:kDefTintColor clickBlock:^(id alertVC) {
                [self deletePhotosWithItem:cell];
            }];
            HKAlertVC *alert = [self alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"请确认是否删除此照片？" ActionItems:@[cancel,confirm]];
            [alert show];
            
        }];
        
        
        id obj = [self.infoPhotosCopy safetyObjectAtIndex:indexPath.row - 1];
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            NSString *urlStr = [obj objectForKey:@"picurl"];
            
            [imageView setImageByUrl:urlStr withType:ImageURLTypeMedium defImage:@"mutualIns_excampleImg" errorImage:@"cm_defpic_fail"];
            
            deleteBtn.hidden = YES;
            
            NSNumber *isAgainUpload = [obj objectForKey:@"isagainupload"];
            maskView.hidden = isAgainUpload.integerValue == 0 ? YES : NO;
            noticeLabel.text = @"需重拍";
            
            overlayView.hidden = YES;
        }
        else if([obj isKindOfClass:[PictureRecord class]])
        {
            PictureRecord *picRcd = (PictureRecord *)obj;
            
            imageView.image = picRcd.image;
            
            if (picRcd.needReupload)
            {
                maskView.hidden = NO;
                noticeLabel.text = @"请重新上传";
            }
            else
            {
                maskView.hidden = YES;
            }
            
            if (picRcd.isUploading)
            {
                deleteBtn.hidden = YES;
                overlayView.hidden = NO;
                [indicator startAnimating];
            }
            else
            {
                deleteBtn.hidden = NO;
                overlayView.hidden = YES;
            }
        }
        
        if (self.infoCanAdd && indexPath.row == self.infoPhotosCopy.count + 1)
        {
            cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"addImgItem" forIndexPath:indexPath];
        }
        
    }
    return cell;
}

-(UICollectionViewCell *)licencePhotoCellForIndexPath:(NSIndexPath *)indexPath
{
    @weakify(self)
    UICollectionViewCell *cell;
    if (indexPath.row == 0)
    {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"titleItem" forIndexPath:indexPath];
        
        UILabel *titleLabel = [cell viewWithTag:100];
        
        titleLabel.text = @"证件照";
    }
    else
    {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"imgViewItem" forIndexPath:indexPath];
        
        UIImageView *imageView = [cell viewWithTag:100];
        UIView *maskView = [cell viewWithTag:101];
        UILabel *noticeLabel = [cell viewWithTag:10101];
        UIButton *deleteBtn = [cell viewWithTag:102];
        UIView *overlayView = [cell viewWithTag:103];
        UIActivityIndicatorView *indicator = [cell viewWithTag:10301];
        
        
        [[[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
            @strongify(self)
            
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
            HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确认" color:kDefTintColor clickBlock:^(id alertVC) {
                [self deletePhotosWithItem:cell];
            }];
            HKAlertVC *alert = [self alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"请确认是否删除此照片？" ActionItems:@[cancel,confirm]];
            [alert show];
            
        }];
        
        
        id obj = [self.licencePhotosCopy safetyObjectAtIndex:indexPath.row - 1];
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            NSString *urlStr = [obj objectForKey:@"picurl"];
            
            [imageView setImageByUrl:urlStr withType:ImageURLTypeMedium defImage:@"mutualIns_excampleImg" errorImage:@"cm_defpic_fail"];
            
            deleteBtn.hidden = YES;
            
            NSNumber *isAgainUpload = [obj objectForKey:@"isagainupload"];
            maskView.hidden = isAgainUpload.integerValue == 0 ? YES : NO;
            noticeLabel.text = @"需重拍";
            
            overlayView.hidden = YES;
        }
        else if([obj isKindOfClass:[PictureRecord class]])
        {
            PictureRecord *picRcd = (PictureRecord *)obj;
            
            imageView.image = picRcd.image;
            
            if (picRcd.needReupload)
            {
                maskView.hidden = NO;
                noticeLabel.text = @"请重新上传";
            }
            else
            {
                maskView.hidden = YES;
            }
            
            if (picRcd.isUploading)
            {
                deleteBtn.hidden = YES;
                overlayView.hidden = NO;
                [indicator startAnimating];
                
            }
            else
            {
                deleteBtn.hidden = NO;
                overlayView.hidden = YES;
            }
        }
        
        if (self.licenceCanAdd && indexPath.row == self.licencePhotosCopy.count + 1)
        {
            cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"addImgItem" forIndexPath:indexPath];
        }
        
    }
    return cell;
}

#pragma mark - Utility

-(BOOL)checkPhotoNeedReupload
{
    if (self.scenePhotosCopy.count - self.scenePhotos.count < self.sceneReupCount)
    {
        return NO;
    }
    else if (self.damagePhotosCopy.count - self.damagePhotos.count < self.damageReupCount)
    {
        return NO;
    }
    else if (self.infoPhotosCopy.count - self.infoPhotos.count < self.infoReupCount)
    {
        return NO;
    }
    else if (self.licencePhotosCopy.count - self.licencePhotos.count < self.licenceReupCount)
    {
        return NO;
    }
    else
    {
        return YES;
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
            //             return [self.scenePhotosCopy safetyObjectAtIndex:indexPath.row];
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
            total = self.damagePhotosCopy.count + 5 + 1;
            break;
        case 2:
            [self.infoPhotosCopy safetyRemoveObjectAtIndex:indexPath.row -1];
            total = self.infoPhotosCopy.count + 5 + 1;
            break;
        case 3:
            [self.licencePhotosCopy safetyRemoveObjectAtIndex:indexPath.row -1];
            total = self.licencePhotosCopy.count + 5 + 1;
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
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        UIImageView *imgView = [cell viewWithTag:100];
        self.img = imgView.image;
        
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
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            UIImageView *imgView = [cell viewWithTag:100];
            self.img = imgView.image;
            
            SDPhotoBrowser *photoBrowser = [SDPhotoBrowser new];
            photoBrowser.delegate = self;
            photoBrowser.imageCount = 1;
            photoBrowser.sourceImagesContainerView = cell;
            
            [photoBrowser show];
        }
        else if (picRecd.needReupload)
        {
            
            [self uploadFileWithPicRecord:picRcd andIndex:indexPath];
        }
    }
}

-(void)takePhotoWithIndexPath:(NSIndexPath *)indexPath
{
    
    
    
#if !TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    
    
    [[[self.picker rac_pickImageInTargetVC:self inView:self.navigationController.view] flattenMap:^RACStream *(UIImage *img) {
        
        PictureRecord *picRcd = [[PictureRecord alloc]init];
        picRcd.image = img;
        [self addPictureRecord:picRcd withIndex:indexPath];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
        
        GetSystemTimeOp *op = [GetSystemTimeOp operation];
        return [[op rac_postRequest]flattenMap:^RACStream *(GetSystemTimeOp *op) {
            self.waterMarkStr = op.rsp_systime;
            return [self addPrinting:op.rsp_systime InPhoto:img];
        }];
    }]subscribeNext:^(UIImage *img) {
        
        PictureRecord *picRcd = [self getPictureRecordWithIndexPath:indexPath];
        picRcd.image = img;
        // 上传图片
        [self uploadFileWithPicRecord:picRcd andIndex:indexPath];
    }error:^(NSError *error) {
        
        [gToast showMistake:error.domain.length != 0 ? error.domain : @"网络连接失败，请检查你的网络设置"];
    }];
    
#else
    
    [[[self.picker rac_pickPhotoTargetVC:self inView:self.navigationController.view] flattenMap:^RACStream *(UIImage *img) {
        
        PictureRecord *picRcd = [[PictureRecord alloc]init];
        picRcd.isUploading = YES;
        picRcd.image = img;
        [self addPictureRecord:picRcd withIndex:indexPath];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
        
        GetSystemTimeOp *op = [GetSystemTimeOp operation];
        return [[op rac_postRequest]flattenMap:^RACStream *(GetSystemTimeOp *op) {
            self.waterMarkStr = op.rsp_systime;
            return [self addPrinting:op.rsp_systime InPhoto:img];
        }];
    }]subscribeNext:^(UIImage *img) {
        
        PictureRecord *picRcd = [self getPictureRecordWithIndexPath:indexPath];
        picRcd.image = img;
        // 上传图片
        [self uploadFileWithPicRecord:picRcd andIndex:indexPath];
    }error:^(NSError *error) {
        
        PictureRecord *picRcd = [self getPictureRecordWithIndexPath:indexPath];
        picRcd.isUploading = NO;
        picRcd.needReupload = YES;
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
        [gToast showMistake:error.domain.length != 0 ? error.domain : @"网络连接失败，请检查你的网络设置"];
    }];
#endif
}

-(void)gotoMutualInsScencePageVCWithReport:(NSDictionary *)report andNotice:(NSArray *)notice
{
    MutualInsScencePageVC *scencePageVC = [UIStoryboard vcWithId:@"MutualInsScencePageVC" inStoryboard:@"MutualInsClaims"];
    scencePageVC.noticeArr = notice;
    scencePageVC.claimid = report[@"claimid"];
    [self.navigationController pushViewController:scencePageVC animated:YES];
}

-(void)gotoChooseCarListVCWithReport:(NSArray *)report andNotice:(NSArray *)notice
{
    MutualInsChooseCarVC *chooseVC = [UIStoryboard vcWithId:@"MutualInsChooseCarVC" inStoryboard:@"MutualInsClaims"];
    chooseVC.noticeArr = notice;
    chooseVC.reports = report;
    [self.navigationController pushViewController:chooseVC animated:YES];
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
            [self getScencePageData];
            
        }];
    }
}

-(RACSignal *)addPrinting:(NSString *)time InPhoto:(UIImage *)img
{
    RACSubject *subject = [RACSubject subject];
    CKAsyncHighQueue(^{
        
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
        
        UIGraphicsEndImageContext();
        
        CKAsyncMainQueue(^{
            [subject sendNext:newImg];
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

-(void)back
{
    if (self.scenePhotosCopy.count - self.scenePhotos.count > 0 ||
        self.damagePhotosCopy.count - self.damagePhotos.count > 0 ||
        self.infoPhotosCopy.count - self.infoPhotos.count > 0 ||
        self.licencePhotosCopy.count - self.licencePhotos.count > 0)
    {
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"去意已决" color:kDefTintColor clickBlock:^(id alertVC) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        HKAlertVC *alert = [self alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"请确认是否放弃重新拍摄的照片并且返回？" ActionItems:@[cancel,confirm]];
        [alert show];
    }
    else if (self.scenePhotosCopy.count - self.scenePhotos.count == 0 &&
             self.damagePhotosCopy.count - self.damagePhotos.count == 0 &&
             self.infoPhotosCopy.count - self.infoPhotos.count == 0 &&
             self.licencePhotosCopy.count - self.licencePhotos.count == 0)
    {
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"去意已决" color:kDefTintColor clickBlock:^(id alertVC) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        HKAlertVC *alert = [self alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"您仍有照片需要重新拍摄上传，请确认是否放弃重新拍摄并且返回？" ActionItems:@[cancel,confirm]];
        [alert show];
    }
}


#pragma mark - SDPhotoBrowserDelegate

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    return self.img;
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
        
        @strongify(self)
        
        [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:CGPointMake(self.view.center.x, self.view.center.y * 0.7)];
        
    }]subscribeNext:^(RACTuple *arr) {
        
        @strongify(self)
        
        [self.view stopActivityAnimation];
        
        GetCoorperationClaimConfigOp *claimConfigOp = arr.first;
        GetCooperationMyCarOp *carOp = arr.second;
        
        NSArray *noticeArr = @[claimConfigOp.rsp_scenedesc,claimConfigOp.rsp_cardamagedesc,claimConfigOp.rsp_carinfodesc,claimConfigOp.rsp_idinfodesc];
        
        [self gotoMutualInsScencePageVCWithReport:carOp.rsp_reports.firstObject andNotice:noticeArr];
        
    } error:^(NSError *error) {
        
        [self.view stopActivityAnimation];
        [gToast showMistake:error.domain];
        
    }];
}

@end
