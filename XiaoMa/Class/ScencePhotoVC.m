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

@interface ScencePhotoVC ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) NSMutableArray *imgArr;
@property (strong, nonatomic) NSMutableArray *urlArr;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIImage *img;

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
    if (self.imgArr.count == 0)
    {
        return 3;
    }
    else if (self.imgArr.count == self.maxCount)
    {
        NSInteger count = self.imgArr.count + 2;
        return count;
    }
    else
    {
        NSInteger count = self.imgArr.count + 3;
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
        return 180;
    }
    else if (indexPath.section == 1)
    {
        return UITableViewAutomaticDimension;
    }
    else if (self.imgArr.count != 0 && indexPath.section == (2 + self.imgArr.count))
    {
        return 60;
    }
    else if (self.imgArr.count == 0 && indexPath.section == 2)
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
    if (indexPath.section == 2 && self.imgArr.count == 0)
    {
        [self takePhoto];
    }
    else if (self.imgArr.count != 0 && indexPath.section == (self.imgArr.count + 2))
    {
        [self takePhoto];
    }
    else if (self.imgArr.count != 0 && indexPath.section > 1)
    {
        PhotoBrowserVC *photoBrowserVC = [[UIStoryboard storyboardWithName:@"MutualInsClaims" bundle:nil]instantiateViewControllerWithIdentifier:@"PhotoBrowserVC"];
        photoBrowserVC.img = [self.imgArr safetyObjectAtIndex:indexPath.section - 2];
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
    else if (self.imgArr.count == 0 && indexPath.section == 2)
    {
        cell = [self takePhotoCellForRowAtIndexPath:indexPath];
    }
    else if (self.imgArr.count != 0 && indexPath.section == (2 + self.imgArr.count))
    {
        cell =[self addPhotoCellForRowAtIndexPath:indexPath];
    }
    else if (self.imgArr.count != 0)
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
    label.text = [self.scencePhotoVM noticeForIndex:self.index];
    return cell;
}

-(UITableViewCell *)takePhotoCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"takePhotoCell"];
    UIView *backgroundView = [cell viewWithTag:100];
    backgroundView.layer.borderWidth = 1;
    backgroundView.layer.borderColor = [[UIColor colorWithHex:@"#dedfe0" alpha:1]CGColor];
    return cell;
}

-(UITableViewCell *)addPhotoCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"addPhotoCell"];
    UIView *view = [cell viewWithTag:100];
    view.layer.borderWidth = 1;
    view.layer.borderColor = [[UIColor colorWithHex:@"#dedfe0" alpha:1]CGColor];
    return cell;
}

-(UITableViewCell *)photoCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"photoCell"];
    UIImageView *imgView = [cell viewWithTag:100];
    imgView.image = [self.imgArr safetyObjectAtIndex:(indexPath.section - 2)];
    UIButton *deleteBtn = [cell viewWithTag:101];
    [[[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        [self deletePhoto:indexPath];
    }];
    return cell;
}

#pragma mark Utility

-(BOOL)canPush
{
    return self.imgArr.count == 0 ? NO : YES;
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
            [self.imgArr safetyRemoveObjectAtIndex:(indexPath.section - 2)];
            [self.urlArr safetyRemoveObjectAtIndex:(indexPath.section - 2)];
            [self.tableView reloadData];
        }
    }];
}
/**
 *  拍照
 */
-(void)takePhoto
{
    HKImagePicker *picker = [HKImagePicker imagePicker];
    picker.compressedSize = CGSizeMake(1024, 1024);
    [[[[picker rac_pickImageInTargetVC:self inView:self.navigationController.view] flattenMap:^RACStream *(UIImage *img) {
        CKAsyncMainQueue(^{
            [gToast showingWithText:@"正在上传"];
        });
        //        @ 叶志成 写op获得时间
        return [self addPrinting:@"2016-3-11 15:33" InPhoto:img];
    }] flattenMap:^RACStream *(UIImage *img) {
        //@ 叶志成 改op
        self.img = img;
        UploadFileOp *op = [UploadFileOp new];
        op.req_fileType = UploadFileTypeDrivingLicenseAndOther;
        NSData *data = UIImageJPEGRepresentation(img, 0.5);
        op.req_fileDataArray = [NSArray arrayWithObject:data];
        op.req_fileExtType = @"jpg";
        return [[op rac_postRequest] map:^id(UploadFileOp *rspOp) {
            return [rspOp.rsp_urlArray safetyObjectAtIndex:0];
        }];
    }] subscribeNext:^(NSString *url) {
        [gToast showSuccess:@"上传成功!"];
        [self.imgArr safetyAddObject:self.img];
        [self.urlArr safetyAddObject:url];
        [self.tableView reloadData];
    }error:^(NSError *error) {
        [gToast showError:error.domain];
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

-(NSMutableArray *)urlArr
{
    if (!_urlArr)
    {
        _urlArr = [self.scencePhotoVM urlArrForIndex:self.index];
    }
    return _urlArr;
}

-(NSMutableArray *)imgArr
{
    if (!_imgArr)
    {
        _imgArr = [self.scencePhotoVM imgArrForIndex:self.index];
    }
    return _imgArr;
}

-(ScencePhotoVM *)scencePhotoVM
{
    if (!_scencePhotoVM)
    {
        _scencePhotoVM = [ScencePhotoVM sharedManager];
    }
    return _scencePhotoVM;
}

@end
