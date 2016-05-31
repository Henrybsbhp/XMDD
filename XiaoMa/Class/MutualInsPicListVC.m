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

@interface MutualInsPicListVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,SDPhotoBrowserDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (assign, nonatomic) BOOL firstswitch;
@property (assign, nonatomic) BOOL sceneCanAdd;
@property (assign, nonatomic) BOOL damageCanAdd;
@property (assign, nonatomic) BOOL infoCanAdd;
@property (assign, nonatomic) BOOL licenceCanAdd;

@property (strong, nonatomic) HKImagePicker *picker;

//
@property (strong, nonatomic) NSArray *scenePhotos;
@property (strong, nonatomic) NSArray *damagePhotos;
@property (strong, nonatomic) NSArray *infoPhotos;
@property (strong, nonatomic) NSArray *licencePhotos;

@property (strong, nonatomic) NSMutableArray *scenePhotosCopy;
@property (strong, nonatomic) NSMutableArray *damagePhotosCopy;
@property (strong, nonatomic) NSMutableArray *infoPhotosCopy;
@property (strong, nonatomic) NSMutableArray *licencePhotosCopy;

@property (strong, nonatomic) UIImage *img;

@end

@implementation MutualInsPicListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化加载数据
    [self loadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Network

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
        
        if (carOp.rsp_reports.count == 1)
        {
            [self gotoMutualInsScencePageVCWithReport:carOp.rsp_reports.firstObject andNotice:noticeArr];
        }
        else if (carOp.rsp_reports.count > 1)
        {
            [self gotoChooseCarListVCWithReport:carOp.rsp_reports andNotice:noticeArr];
        }
        else
        {
            [self showHKImageAlertVC];
        }
        
    } error:^(NSError *error) {
        
        [self.view stopActivityAnimation];
        [gToast showMistake:error.domain];
        
    }];
}



-(void)loadData
{
    @weakify(self)
    GetPicListOp *op = [GetPicListOp operation];
    //    op.req_claimid = self.claimID;
    op.req_claimid = @(309);
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
    } error:^(NSError *error) {
        [gToast showError:@"上传照片失败"];
    }];
}



-(void)uploadFileWithPicRecord:(PictureRecord *)picrecord andIndex:(NSIndexPath *)indexPath
{
    // 将图片的上传中属性设为YES。判断是否转菊花
    picrecord.isUploading = YES;
    
    // 每添加一张照片判断照片所属类型
    switch (indexPath.section)
    {
        case 0:
            [self.scenePhotosCopy addObject:picrecord];
            break;
        case 1:
            [self.damagePhotosCopy addObject:picrecord];
            break;
        case 2:
            [self.infoPhotosCopy addObject:picrecord];
            break;
        case 3:
            [self.licencePhotosCopy addObject:picrecord];
            break;
    }
    
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
            count = self.scenePhotosCopy.count + 1 + (self.sceneCanAdd ? 1 : 0);
            break;
        case 1:
            count = self.damagePhotosCopy.count + 1 + (self.damageCanAdd ? 1 : 0);
            break;
        case 2:
            count = self.infoPhotosCopy.count + 1 + (self.infoCanAdd ? 1 : 0);
            break;
        case 3:
            count = self.licencePhotosCopy.count + 1 + (self.licenceCanAdd ? 1 : 0);
            break;
        default:
            count = 1;
            break;
    }
    
    //    count = section == 4 ? 1 : 5;
    
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
    if(indexPath.row != 0)
    {
        // 判断是否能添加照片。
        // 判断后台是否支持上传。判断是否已经添加。判断是否点击最后一个。
        if ([self canAddNewPhotoWithIndexPath:indexPath])
        {
            
#if !TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
            
            [[self.picker rac_pickImageInTargetVC:self inView:self.navigationController.view]subscribeNext:^(UIImage *img) {
                
                PictureRecord *picRcd = [[PictureRecord alloc]init];
                picRcd.image = img;
                // 上传图片
                [self uploadFileWithPicRecord:picRcd andIndex:indexPath];
                
            }error:^(NSError *error) {
                [gToast showMistake:error.domain];
            }];
#else
            [[self.picker rac_pickPhotoTargetVC:self inView:self.navigationController.view]subscribeNext:^(UIImage *img) {
                
                PictureRecord *picRcd = [[PictureRecord alloc]init];
                picRcd.image = img;
                // 上传图片
                [self uploadFileWithPicRecord:picRcd andIndex:indexPath];
            }error:^(NSError *error) {
                [gToast showMistake:error.domain];
            }];
#endif
        }
        else
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
        UIActivityIndicatorView *indicator = [cell viewWithTag:103];
        
        [[[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
            @strongify(self)
            [self.scenePhotosCopy safetyRemoveObjectAtIndex:indexPath.row -1];
            //            [self.collectionView reloadData];
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        }];
        
        
        id obj = [self.scenePhotosCopy safetyObjectAtIndex:indexPath.row - 1];
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            NSString *urlStr = [obj objectForKey:@"picurl"];
            [imageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"excampleImg"]];
            
            deleteBtn.hidden = YES;
            
            NSNumber *isAgainUpload = [obj objectForKey:@"isagainupload"];
            maskView.hidden = isAgainUpload.integerValue == 0 ? YES : NO;
            noticeLabel.text = @"需重拍";
            
            indicator.hidden = YES;
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
                indicator.hidden = NO;
                deleteBtn.hidden = YES;
                [indicator startAnimating];
            }
            else
            {
                deleteBtn.hidden = NO;
                indicator.hidden = YES;
            }
        }
        
        if (self.sceneCanAdd && indexPath.row == self.scenePhotosCopy.count)
        {
            imageView.hidden = NO;
            maskView.hidden = YES;
            deleteBtn.hidden = YES;
            indicator.hidden = YES;
            
            imageView.image = [UIImage imageNamed:@"mutualIns_addPhoto"];
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
        UIActivityIndicatorView *indicator = [cell viewWithTag:103];
        
        [[[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
            @strongify(self)
            [self.damagePhotosCopy safetyRemoveObjectAtIndex:indexPath.row -1];
            //            [self.collectionView reloadData];
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        }];
        
        
        id obj = [self.damagePhotosCopy safetyObjectAtIndex:indexPath.row - 1];
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            NSString *urlStr = [obj objectForKey:@"picurl"];
            [imageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"excampleImg"]];
            
            deleteBtn.hidden = YES;
            
            NSNumber *isAgainUpload = [obj objectForKey:@"isagainupload"];
            maskView.hidden = isAgainUpload.integerValue == 0 ? YES : NO;
            noticeLabel.text = @"需重拍";
            
            indicator.hidden = YES;
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
                indicator.hidden = NO;
                [indicator startAnimating];
            }
            else
            {
                indicator.hidden = YES;
            }
        }
        
        if (self.damageCanAdd && indexPath.row == self.damagePhotosCopy.count)
        {
            imageView.hidden = NO;
            maskView.hidden = YES;
            deleteBtn.hidden = YES;
            indicator.hidden = YES;
            
            imageView.image = [UIImage imageNamed:@"mutualIns_addPhoto"];
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
        UIActivityIndicatorView *indicator = [cell viewWithTag:103];
        
        [[[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
            @strongify(self)
            [self.infoPhotosCopy safetyRemoveObjectAtIndex:indexPath.row -1];
            //            [self.collectionView reloadData];
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        }];
        
        id obj = [self.infoPhotosCopy safetyObjectAtIndex:indexPath.row - 1];
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            NSString *urlStr = [obj objectForKey:@"picurl"];
            [imageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"excampleImg"]];
            
            deleteBtn.hidden = YES;
            
            NSNumber *isAgainUpload = [obj objectForKey:@"isagainupload"];
            maskView.hidden = isAgainUpload.integerValue == 0 ? YES : NO;
            noticeLabel.text = @"需重拍";
            
            indicator.hidden = YES;
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
                indicator.hidden = NO;
                [indicator startAnimating];
            }
            else
            {
                indicator.hidden = YES;
            }
        }
        
        if (self.infoCanAdd && indexPath.row == self.infoPhotosCopy.count)
        {
            imageView.hidden = NO;
            maskView.hidden = YES;
            deleteBtn.hidden = YES;
            indicator.hidden = YES;
            
            imageView.image = [UIImage imageNamed:@"mutualIns_addPhoto"];
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
        UIActivityIndicatorView *indicator = [cell viewWithTag:103];
        
        [[[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
            @strongify(self)
            [self.licencePhotosCopy safetyRemoveObjectAtIndex:indexPath.row -1];
            //            [self.collectionView reloadData];
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        }];
        
        id obj = [self.licencePhotosCopy safetyObjectAtIndex:indexPath.row - 1];
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            NSString *urlStr = [obj objectForKey:@"picurl"];
            [imageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"excampleImg"]];
            
            deleteBtn.hidden = YES;
            
            NSNumber *isAgainUpload = [obj objectForKey:@"isagainupload"];
            maskView.hidden = isAgainUpload.integerValue == 0 ? YES : NO;
            noticeLabel.text = @"需重拍";
            
            indicator.hidden = YES;
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
                indicator.hidden = NO;
                [indicator startAnimating];
            }
            else
            {
                indicator.hidden = YES;
            }
        }
        
        if (self.licenceCanAdd && indexPath.row == self.licencePhotosCopy.count)
        {
            imageView.hidden = NO;
            maskView.hidden = YES;
            deleteBtn.hidden = YES;
            indicator.hidden = YES;
            
            imageView.image = [UIImage imageNamed:@"mutualIns_addPhoto"];
        }
        
    }
    return cell;
}

#pragma mark - Utility

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
            indexPath.row != self.scenePhotosCopy.count)
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
            indexPath.row != self.damagePhotosCopy.count)
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
            indexPath.row != self.infoPhotosCopy.count)
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
            indexPath.row != self.licencePhotosCopy.count)
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
    //    @YZC 显示默认页。可以上传添加按钮。不可以上传不显示按钮
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
            //            @YZC 跳转至拍照页面
            [self getScencePageData];
        }];
    }
}

-(void)showHKImageAlertVC
{
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *makePhone = [HKAlertActionItem itemWithTitle:@"电话报案" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
        [gPhoneHelper makePhone:@"4007111111"];
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"未检测到您的爱车有车险报案记录，快速补偿需要先报案后才能进行现场拍照。请先报案，谢谢～" ActionItems:@[cancel,makePhone]];
    [alert show];
}

#pragma mark - LazyLoad

-(HKImagePicker *)picker
{
    if (!_picker)
    {
        _picker = [HKImagePicker imagePicker];
        //        _picker.compressedSize = CGSizeMake(1024, 1024);
    }
    return _picker;
}

-(NSMutableArray *)scenePhotosCopy
{
    if (!_scenePhotosCopy)
    {
        _scenePhotosCopy = [[NSMutableArray alloc]init];
    }
    return _scenePhotosCopy;
}

#pragma mark - Action


#pragma mark - SDPhotoBrowserDelegate

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    return self.img;
}


@end
