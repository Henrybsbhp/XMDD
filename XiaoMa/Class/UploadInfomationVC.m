//
//  UploadInfomationVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/12.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UploadInfomationVC.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "XiaoMa.h"
#import "JGActionSheet.h"

@interface UploadInfomationVC ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) NSMutableArray *datasource;
@end

@implementation UploadInfomationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadDatasource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadDatasource
{
    self.datasource = [NSMutableArray arrayWithArray:@[@NO,@NO,@NO]];
    [self.tableView reloadData];
}

#pragma mark - Action
- (IBAction)actionHelp:(id)sender
{
    
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    UIView *container1 = (UIView *)[cell.contentView viewWithTag:100];
    UIImageView *imgV2 = (UIImageView *)[cell.contentView viewWithTag:1002];
    
    UIImage *img = [self.datasource safetyObjectAtIndex:indexPath.row];
    if ([img isKindOfClass:[UIImage class]]) {
        container1.hidden = YES;
        imgV2.hidden = NO;
        imgV2.image = img;
    }
    else {
        container1.hidden = NO;
        imgV2.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"拍照",@"从相册选择"]
                                                                buttonStyle:JGActionSheetButtonStyleDefault];
    JGActionSheetSection *section2 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"取消"]
                                                                buttonStyle:JGActionSheetButtonStyleCancel];
    JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:@[section1, section2]];
    [sheet showInView:self.navigationController.view animated:YES];
    
    //显示水印的例子图片
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 280, 175)];
    imgV.image = [UIImage imageNamed:[NSString stringWithFormat:@"ins_pic%d", (int)indexPath.row+1]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 185, 260, 40)];
    label.numberOfLines = 2;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor whiteColor];
    label.text = @"所有上传资料均会加水印，小马达达保障您的安全！";
    
    CGFloat boundWidth = self.navigationController.view.bounds.size.width;
    CGFloat boundHeight = sheet.frame.size.height - sheet.scrollViewHost.frame.size.height;
    UIView *exampleView = [[UIView alloc] initWithFrame:CGRectMake((boundWidth-280)/2, (boundHeight-224)/2+30, 280, 224)];
    exampleView.backgroundColor = [UIColor clearColor];
    [exampleView addSubview:imgV];
    [exampleView addSubview:label];
    exampleView.hidden = YES;
    [sheet addSubview:exampleView];
    [exampleView setHidden:NO animated:YES];

    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *sheetIndexPath) {
        
        [exampleView setHidden:YES animated:YES];
        [sheet dismissAnimated:YES];
        //拍照
        if (sheetIndexPath.section == 0 && sheetIndexPath.row == 0)
        {
            if ([UIImagePickerController isFrontCameraAvailable])
            {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.delegate = self;
                controller.allowsEditing = YES;
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.customObject = indexPath;
                [self presentViewController:controller animated:YES completion:nil];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该设备不支持拍照" message:nil delegate:nil
                                                      cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }
        }
        // 从相册中选取
        else if (sheetIndexPath.section == 0 && sheetIndexPath.row == 1)
        {
            if ([UIImagePickerController isPhotoLibraryAvailable])
            {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.delegate = self;
                controller.allowsEditing = YES;
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.customObject = indexPath;
                [self presentViewController:controller animated:YES completion:nil];
            }
        }

    }];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *portraitImg = [info objectForKey:UIImagePickerControllerEditedImage];
    NSIndexPath *indexPath = picker.customObject;
    [self.datasource safetyReplaceObjectAtIndex:indexPath.row withObject:portraitImg];
    [self.tableView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
