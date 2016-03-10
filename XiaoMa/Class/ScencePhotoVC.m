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
#import "SDPhotoBrowser.h"

@interface ScencePhotoVC ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,SDPhotoBrowserDelegate>
@property (strong, nonatomic) IBOutlet UIButton *nextStepBtn;
@property (strong, nonatomic) IBOutlet HKProgressView *progressView;
@property (nonatomic) BOOL hasPhoto;
@property (strong, nonatomic) NSMutableArray *imgArr;
@property (strong, nonatomic) NSMutableArray *urlArr;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ScencePhotoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self configProgressView];
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
    else if (self.imgArr.count != 0)
    {
        UITableViewCell *cell = [self photoCellForRowAtIndexPath:indexPath];
        UIImageView *imgView = [cell viewWithTag:100];
        SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
        UIView *sourceImgV1 = imgView;
        imgView.frame = CGRectMake(200, 200, imgView.frame.size.width, imgView.frame.size.height);
        browser.sourceImagesContainerView = sourceImgV1;
        browser.imageCount = 1; // 图片总数
        browser.currentImageIndex = 0 ;
        browser.delegate = self;
        [browser show];
        //        SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
        //        UIView *sourceImgV1 = self.headImgView;
        //        browser.sourceImageViews = @[sourceImgV1]; // 原图的容器
        //        browser.imageCount = self.shop.picArray.count; // 图片总数
        //        browser.currentImageIndex = 0;
        //        browser.delegate = self;
        //        [browser show];
    }
}

-(UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    NSLog(@"%ld",index);
    return [self.imgArr safetyObjectAtIndex:index];
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
    return [self.tableView dequeueReusableCellWithIdentifier:@"photoSampleCell"];
}

-(UITableViewCell *)noticeCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.tableView dequeueReusableCellWithIdentifier:@"noticeCell"];
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

-(void)deletePhoto:(NSIndexPath *)indexPath
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"删除照片" message:@"请确认是否删除照片?" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    [[alertView rac_buttonClickedSignal]subscribeNext:^(id x) {
        [self.imgArr safetyRemoveObjectAtIndex:(indexPath.section - 2)];
        [self.tableView reloadData];
    }];
}

-(void)takePhoto
{
    //@ 叶志成 改op
    HKImagePicker *picker = [HKImagePicker imagePicker];
    picker.compressedSize = CGSizeMake(1024, 1024);
    [[[picker rac_pickImageInTargetVC:self inView:self.navigationController.view] flattenMap:^RACStream *(UIImage *img) {
        CKAsyncMainQueue(^{
            [gToast showingWithText:@"正在上传"];
            [self.imgArr safetyAddObject:img];
            self.hasPhoto = YES;
        });
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
        [self.urlArr safetyAddObject:url];
        [self.tableView reloadData];
    }error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}


#pragma mark Init

-(void)setupUI
{
    self.nextStepBtn.layer.cornerRadius = 5;
    self.nextStepBtn.layer.masksToBounds = YES;
}

-(void)configProgressView
{
    self.progressView.titleArray = @[@"现场接触",@"车辆损失",@"车辆信息",@"证件照"];
    self.progressView.selectedIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)];
    self.progressView.normalColor = [UIColor colorWithHex:@"#f7f7f8" alpha:1];
}

#pragma mark Action

- (IBAction)nextStepAction:(id)sender {
    //    @叶志成 下一步操作
}

#pragma mark LazyLoad

-(NSMutableArray *)urlArr
{
    if (!_urlArr)
    {
        _urlArr = [[NSMutableArray alloc]init];
    }
    return _urlArr;
}

-(NSMutableArray *)imgArr
{
    if (!_imgArr)
    {
        _imgArr = [[NSMutableArray alloc]init];
    }
    return _imgArr;
}

@end
