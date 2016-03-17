//
//  ScencePhotoVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/9.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ScencePhotoVC.h"
#import "HKProgressView.h"
#import "HKImagePicker.h"
#import "UploadFileOp.h"
#import "PhotoBrowserVC.h"
#import "ScencePhotoVM.h"
#import "GetSystemTimeOp.h"
#import "HKImageView.h"
#import "PictureRecord.h"

@interface ScencePhotoVC ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong)NSMutableArray * recordArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) ScencePhotoVM *scencePhotoVM;

@property (nonatomic) NSInteger maxCount;

@end

@implementation ScencePhotoVC

- (void)dealloc
{
    
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 200;
    }
    else if (indexPath.section == 1)
    {
        return UITableViewAutomaticDimension;
    }
    else if (self.recordArray.count != 0 && indexPath.section == (2 + self.recordArray.count))
    {
        return 60;
    }
    else if (self.recordArray.count == 0 && indexPath.section == 2)
    {
        return 200;
    }
    else
    {
        return 165;
    }
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && self.recordArray.count == 0)
    {
        [self takePhotoWithIndexPath:indexPath];
    }
    else if (self.recordArray.count != 0 && indexPath.section == (self.recordArray.count + 2))
    {
        [self takePhotoWithIndexPath:indexPath];
    }
    else if (self.recordArray.count != 0 && indexPath.section > 1)
    {
        PhotoBrowserVC *photoBrowserVC = [[UIStoryboard storyboardWithName:@"MutualInsClaims" bundle:nil]instantiateViewControllerWithIdentifier:@"PhotoBrowserVC"];
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
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    HKImageView * hkimageview  = [view viewWithTag:10101];
    if (!hkimageview)
    {
        hkimageview = [[HKImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 60, 165)];
        hkimageview.contentMode = UIViewContentModeScaleAspectFill;
        hkimageview.tag = 10101;
        [view addSubview:hkimageview];
    }

    PictureRecord * record = [self.recordArray safetyObjectAtIndex:indexPath.section - 2];
    [[[hkimageview.reuploadButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntilForCell:cell] subscribeNext:^(id x) {
        
        record.needReupload = YES;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    if ((!record.url.length && !record.isUploading && !record.needReupload)
        || record.needReupload)
    {
        [self uploadImage:hkimageview andRecord:record andCell:cell];
    }
    else
    {
        hkimageview.image = record.image;
    }
    
    UIButton *deleteBtn = [cell viewWithTag:101];
    [[[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        [self deletePhoto:indexPath];
    }];
    return cell;
}

- (void)uploadImage:(HKImageView *)imageView andRecord:(PictureRecord *)record andCell:(UITableViewCell * )cell
{
    @weakify(imageView)
    [[[imageView rac_setUploadingImage:record.image withImageType:UploadFileTypeMutualIns] initially:^{
        
        record.isUploading = YES;
    }] subscribeNext:^(UploadFileOp *op) {
        
        record.isUploading = NO;
        record.needReupload = NO;
        record.url = [op.rsp_urlArray safetyObjectAtIndex:0];
    } error:^(NSError *error) {
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

-(NSString *)canPush
{
    for (PictureRecord * rc in self.recordArray)
    {
        if (rc.isUploading)
        {
            return @"图片正在上传，请稍后";
        }
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
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"删除照片" message:@"请确认是否删除照片?" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    [[alertView rac_buttonClickedSignal]subscribeNext:^(NSNumber *x) {
        if (x.integerValue == 1)
        {
            [self.recordArray safetyRemoveObjectAtIndex:indexPath.section - 2];
            [self.tableView reloadData];
        }
    }];
}
/**
 *  拍照
 */
-(void)takePhotoWithIndexPath:(NSIndexPath *)indexpath
{
    HKImagePicker *picker = [HKImagePicker imagePicker];
    picker.compressedSize = CGSizeMake(1024, 1024);
    [[[picker rac_pickImageInTargetVC:self inView:self.navigationController.view] flattenMap:^RACStream *(UIImage *img) {

        GetSystemTimeOp *op = [[GetSystemTimeOp alloc]init];
        return [[op rac_postRequest] flattenMap:^id(GetSystemTimeOp *op) {
            return [self addPrinting:op.rsp_systime InPhoto:img];
        }];
    }] subscribeNext:^(UIImage *img) {
        
        PictureRecord * record = [[PictureRecord alloc] init];
        record.image = img;
        record.customObject = indexpath;
        [self.recordArray safetyAddObject:record];
        [self.tableView reloadData];
    }];
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
-(ScencePhotoVM *)scencePhotoVM
{
    if (!_scencePhotoVM)
    {
        _scencePhotoVM = [ScencePhotoVM sharedManager];
    }
    return _scencePhotoVM;
}

- (NSMutableArray *)recordArray
{
    if (!_recordArray)
        _recordArray = [NSMutableArray array];
    return _recordArray;
}

@end
