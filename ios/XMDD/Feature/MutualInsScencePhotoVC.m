//
//  MutualInsScencePhotoVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/9.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsScencePhotoVC.h"
#import "HKProgressView.h"
#import "HKImagePicker.h"
#import "UploadFileOp.h"
#import "MutualInsPhotoBrowserVC.h"
#import "MutualInsScencePhotoVM.h"
#import "GetSystemTimeOp.h"
#import "HKImageView.h"
#import "PictureRecord.h"
#import "Reachability.h"

@interface MutualInsScencePhotoVC ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong)NSMutableArray * recordArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSInteger maxCount;

@property (strong, nonatomic) NSString *waterMarkStr;

@end

@implementation MutualInsScencePhotoVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"MutualInsScencePhotoVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.maxCount = [self.scencePhotoVM maxPhotoNumForIndex:self.index];
    if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
    {
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.recordArray.count == self.maxCount)
    {
        NSInteger count = self.recordArray.count + 2;
        return count;
    }
    else
    {
        NSInteger count = self.recordArray.count + 3;
        return count;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return CGFLOAT_MIN;
    }
    return 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, gAppMgr.deviceInfo.screenSize.width, 10);
    view.backgroundColor = [UIColor clearColor];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 200;
    }
    else if (indexPath.section == 1 )
    {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        [cell layoutIfNeeded];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
        return ceil(size.height);
    }
    else if (self.recordArray.count != 0 && indexPath.section == (2 + self.recordArray.count))
    {
        //加符号
        return 60;
    }
    else if (self.recordArray.count == 0 && indexPath.section == 2)
    {
        // 第一张空白图片
        CGFloat width = gAppMgr.deviceInfo.screenSize.width - 60;
        CGFloat height = 666.0 / 1024 * width;
        return height;
    }
    else
    {
        // 有照片的cell
        CGFloat width = gAppMgr.deviceInfo.screenSize.width - 60;
        CGFloat height = 666.0 / 1024 * width;
        return height;
    }
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && self.recordArray.count == 0)
    {
        [MobClick event:@"xiaomahuzhu" attributes:@{@"woyaopei":@"woyaopei0008"}];
        [self takePhotoWithIndexPath:indexPath];
    }
    else if (self.recordArray.count != 0 && indexPath.section == (self.recordArray.count + 2))
    {
        
        if ([Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable)
        {
            [gToast showMistake:@"请检查网络连接"];
        }
        else
        {
            [MobClick event:@"xiaomahuzhu" attributes:@{@"woyaopei":@"woyaopei0010"}];
            [self takePhotoWithIndexPath:indexPath];
        }
    }
    else if (self.recordArray.count != 0 && indexPath.section > 1)
    {
        MutualInsPhotoBrowserVC *photoBrowserVC = [[UIStoryboard storyboardWithName:@"MutualInsClaims" bundle:nil]instantiateViewControllerWithIdentifier:@"MutualInsPhotoBrowserVC"];
        PictureRecord * record = [self.recordArray safetyObjectAtIndex:indexPath.section - 2];
        photoBrowserVC.img = record.image;
        [self.navigationController pushViewController:photoBrowserVC animated:YES];
    }
}


#pragma mark UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0 )
    {
        cell = [self photoSampleCellForRowAtIndexPath:indexPath];
    }
    else if (indexPath.section == 1)
    {
        cell = [self noticeCellForRowAtIndexPath:indexPath];
    }
    else if (self.recordArray.count == 0 && indexPath.section == 2)
    {
        cell = [self takePhotoCellForRowAtIndexPath:indexPath];
    }
    else if (self.recordArray.count != 0 && indexPath.section == (2 + self.recordArray.count))
    {
        cell =[self addPhotoCellForRowAtIndexPath:indexPath];
    }
    else if (self.recordArray.count != 0)
    {
        cell = [self photoCellForRowAtIndexPath:indexPath];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(UITableViewCell *)photoSampleCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"photoSampleCell"];
    UIImageView *imgView = [cell viewWithTag:100];
    imgView.image = [self.scencePhotoVM sampleImgForIndex:self.index];
    return cell;
}

-(UITableViewCell *)noticeCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"noticeCell"];
    UILabel *label = [cell viewWithTag:100];
    label.numberOfLines = 0;
    label.preferredMaxLayoutWidth = self.view.bounds.size.width - 50;
    label.text = [self.scencePhotoVM noticeForIndex:self.index];
    return cell;
}

-(UITableViewCell *)takePhotoCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"takePhotoCell"];
    UIView *backgroundView = [cell viewWithTag:100];
    [self addBorder:backgroundView];
    return cell;
}

-(UITableViewCell *)addPhotoCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"addPhotoCell"];
    UIView *view = [cell viewWithTag:100];
    [self addBorder:view];
    return cell;
}

-(UITableViewCell *)photoCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"photoCell"];
    UIView *view = [cell viewWithTag:1000];
    [self addBorder:view];
    
    //放弃子视图约束
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    PictureRecord * record = [self.recordArray safetyObjectAtIndex:indexPath.section - 2];
    //初始化hkimageview。如果为nil则手动创建一个。
    HKImageView * hkimageview  = view.customObject;
    if (!hkimageview)
    {
        CGFloat width = gAppMgr.deviceInfo.screenSize.width - 60;
        CGFloat height = 666.0 / 1024 * width;
        
        hkimageview = [[HKImageView alloc]initWithFrame:CGRectMake(1, 1, self.view.bounds.size.width - 62, height-2)];
        hkimageview.contentMode = UIViewContentModeScaleAspectFit;
        [view addSubview:hkimageview];
        
        view.customObject = hkimageview;
        
        //重新上传照片
        [[[hkimageview.reuploadButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            record.needReupload = YES;
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
        //重新拍照
        [[[hkimageview.pickImageButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
            [self takePhotoWithIndexPath:indexPath];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
    //判断是否需要重新上传照片
    if ((!record.url.length && !record.isUploading && !record.needReupload)
        || record.needReupload)
    {
        [self uploadImage:hkimageview andRecord:record];
    }
    else
    {
        hkimageview.image = record.image;
    }
    
    //删除事件
    UIButton *deleteBtn = [cell viewWithTag:101];
    [[[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        [self deletePhoto:indexPath];
    }];
    
    return cell;
}

/**
 *  上传图片到服务器
 *
 *  @param imageView 触发方法的对象
 *  @param record    上传的对象
 */
- (void)uploadImage:(HKImageView *)imageView andRecord:(PictureRecord *)record
{
    @weakify(imageView)
    [[[imageView rac_setUploadingImage:record.image withImageType:UploadFileTypeMutualIns] initially:^{
        //初始化上传状态为［上传中］
        record.isUploading = YES;
    }] subscribeNext:^(UploadFileOp *op) {
        //上传成功后将上传状态改为［不在上传中］, 并且［不需要重新上传］
        @strongify(imageView)
        record.isUploading = NO;
        record.needReupload = NO;
        imageView.tapGesture.enabled = NO;
        record.url = [op.rsp_urlArray safetyObjectAtIndex:0];
    } error:^(NSError *error) {
        //上传失败后限时遮罩层,并且修改上传状态。
        @strongify(imageView)
        [imageView showMaskView];
        record.isUploading = NO;
        record.needReupload = NO;
    }];
}

#pragma mark Utility


-(void)addBorder:(UIView *)view
{
    view.layer.borderColor = [[UIColor colorWithHex:@"#dedfe0" alpha:1]CGColor];
    view.layer.borderWidth = 1;
}

/**
 *  判断是否能退出或进入下一个页面
 *
 *  @return 如果可以返回空字符。如果不可以上传提示文案
 */

-(NSString *)canPush
{
    if (self.recordArray.count != 0)
    {
        for (PictureRecord * rc in self.recordArray)
        {
            if (rc.isUploading)
            {
                return @"图片正在上传，请稍后";
            }
        }
    }
    else if (self.recordArray.count == 0)
    {
        return @"请先上传照片";
    }
    return @"";
}

/**
 *  删除照片
 *
 *  @param indexPath 索引
 */
-(void)deletePhoto:(NSIndexPath *)indexPath
{
    [MobClick event:@"xiaomahuzhu" attributes:@{@"woyaopei":@"woyaopei0009"}];
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确定" color:kDefTintColor clickBlock:^(id alertVC) {
        [self.recordArray safetyRemoveObjectAtIndex:indexPath.section - 2];
        [self.tableView reloadData];
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"请确认是否删除照片?" ActionItems:@[cancel,confirm]];
    [alert show];
    
}
/**
 *  给照片打水印
 *
 *  @param indexpath 照片的indexpath
 */
-(void)takePhotoWithIndexPath:(NSIndexPath *)indexpath
{
    HKImagePicker *picker = [HKImagePicker imagePicker];
    picker.compressedSize = CGSizeMake(1024, 1024);
    
#if !TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    
    [[[picker rac_pickImageInTargetVC:self inView:self.navigationController.view] flattenMap:^RACStream *(UIImage *img) {
        
        GetSystemTimeOp *op = [[GetSystemTimeOp alloc]init];
        return [[op rac_postRequest] flattenMap:^id(GetSystemTimeOp *op) {
            self.waterMarkStr = op.rsp_systime;
            return [self addPrinting:op.rsp_systime InPhoto:img];
        }];
    }] subscribeNext:^(UIImage *img) {
        
        PictureRecord * record = [[PictureRecord alloc] init];
        //打水印成功后在self.recordArray占一个位置。但是record只有image没有URL
        record.image = img;
        //保证拍照选择不会造成顺序错乱
        [self.recordArray safetyRemoveObjectAtIndex:(indexpath.section - 2)];
        [self.recordArray insertObject:record atIndex:(indexpath.section - 2)];
        //不能进行单cell刷新。因为每次选择照片会多一个cell
        [self.tableView reloadData];
    }error:^(NSError *error) {
        [gToast showMistake:error.domain.length != 0 ? error.domain : @"网络连接失败，请检查你的网络设置"];
    }];
#else
    
    [[[picker rac_pickPhotoTargetVC:self inView:self.navigationController.view] flattenMap:^RACStream *(UIImage *img) {
        GetSystemTimeOp *op = [[GetSystemTimeOp alloc]init];
        return [[op rac_postRequest] flattenMap:^id(GetSystemTimeOp *op) {
            return [self addPrinting:op.rsp_systime InPhoto:img];
        }];
    }] subscribeNext:^(UIImage *img) {
        
        PictureRecord * record = [[PictureRecord alloc] init];
        //打水印成功后在self.recordArray占一个位置。但是record只有image没有URL
        record.image = img;
        //保证拍照选择不会造成顺序错乱
        [self.recordArray safetyRemoveObjectAtIndex:(indexpath.section - 2)];
        [self.recordArray insertObject:record atIndex:(indexpath.section - 2)];
        //不能进行单cell刷新。因为每次选择照片会多一个cell
        [self.tableView reloadData];
    }error:^(NSError *error) {
        [gToast showMistake:error.domain.length != 0 ? error.domain : @"网络连接失败，请检查你的网络设置"];
    }];
#endif
}

/**
 *  给照片打水印
 *
 *  @param time 打印水印
 *  @param img  照片
 *
 *  @return 打印完的照片
 */
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

#pragma mark LazyLoad

- (NSMutableArray *)recordArray
{
    if (!_recordArray)
        _recordArray = [self.scencePhotoVM recordArrayForIndex:self.index];
    return _recordArray;
}

@end
