//
//  ScencePhotoVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/9.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ScencePhotoVC.h"
#import "HKProgressView.h"

@interface ScencePhotoVC ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *nextStepBtn;
@property (strong, nonatomic) IBOutlet HKProgressView *progressView;
@property (nonatomic) BOOL hasPhoto;

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

#pragma mark UITableViewDelegate,UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0 )
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"photoSampleCell"];
    }
    else if (indexPath.section == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"noticeCell"];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"takePhotoCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
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
    else
    {
        return 220;
    }
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        if ([UIImagePickerController isCameraAvailable])
        {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.customInfo[@"target"] = self;
            controller.delegate = self;
            controller.allowsEditing = NO;
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            controller.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            [self presentViewController:controller animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该设备不支持拍照" message:nil delegate:nil
                                                  cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
    }
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
}


@end
