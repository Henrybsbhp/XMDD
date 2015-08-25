//
//  HKImagePicker.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/24.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKImagePicker.h"
@interface HKImagePicker () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, weak) UINavigationController *imgPickerNavCtrl;
@end

@implementation HKImagePicker
- (instancetype)init
{
    self = [super init];
    if (self) {
        _shouldShowBigImage = YES;
        _allowsEditing = NO;
        _shouldCompress = YES;
        _compressedSize = CGSizeMake(1024, 1024);
    }
    return self;
}

- (void)dealloc
{
    
}

+ (instancetype)imagePicker
{
    HKImagePicker *picker = [[HKImagePicker alloc] init];
    return picker;
}

- (RACSignal *)rac_pickImageInTargetVC:(UIViewController *)targetVC inView:(UIView *)view
{
    RACSubject *subject = [RACSubject subject];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选取照片" delegate:nil cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
    [sheet showInView:view];
    [[sheet rac_buttonClickedSignal] subscribeNext:^(NSNumber *x) {
        NSInteger index = [x integerValue];
        //拍照
        if (index == 0)
        {
            if ([UIImagePickerController isCameraAvailable])
            {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.customObject = subject;
                controller.customInfo[@"target"] = self;
                controller.delegate = self;
                controller.allowsEditing = self.allowsEditing;
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                controller.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                [targetVC presentViewController:controller animated:YES completion:nil];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该设备不支持拍照" message:nil delegate:nil
                                                      cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                [subject sendCompleted];
            }
        }
        // 从相册中选取
        else if (index == 1)
        {
            if ([UIImagePickerController isPhotoLibraryAvailable])
            {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.customObject = subject;
                controller.customInfo[@"target"] = self;
                controller.delegate = self;
                controller.allowsEditing = self.allowsEditing;
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                [targetVC presentViewController:controller animated:YES completion:nil];
            }
            else {
                [subject sendCompleted];
            }
        }
    }];
    return subject;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    RACSubject *subject = picker.customObject;
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary && self.shouldShowBigImage) {
        HKImageShowingViewController *vc = [[HKImageShowingViewController alloc] initWithSubject:subject];
        UIImage *img = [info objectForKey:picker.allowsEditing ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage];
        if (self.shouldCompress && self.compressedSize.width > 0 && self.compressedSize.height > 0) {
            img = [img compressImageWithPixelSize:self.compressedSize];
        }
        vc.image = img;
        [self.imgPickerNavCtrl pushViewController:vc animated:YES];
    }
    else {
        [picker dismissViewControllerAnimated:YES completion:nil];
        UIImage *img = [info objectForKey:picker.allowsEditing ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage];
        if (self.shouldCompress && self.compressedSize.width > 0 && self.compressedSize.height > 0) {
            img = [img compressImageWithPixelSize:self.compressedSize];
        }
        [subject sendNext:img];
        [subject sendCompleted];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    RACSubject *subject = picker.customObject;
    [picker dismissViewControllerAnimated:YES completion:nil];
    [subject sendCompleted];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.imgPickerNavCtrl = navigationController;
}

@end

@interface HKImageShowingViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) RACSubject *subject;
@end

@implementation HKImageShowingViewController

- (id)initWithSubject:(RACSubject *)subject
{
    self = [super init];
    _subject = subject;
    return self;
}

- (void)dealloc
{
    
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor blackColor];
    //setup imageView
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    @weakify(self);
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self.view);
    }];
    self.imageView.image = self.image;
    //setup navigationBar
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(actionCancel:)];
    UIBarButtonItem *finish = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(actionFinish:)];
    [self.navigationItem setLeftBarButtonItem:cancel];
    [self.navigationItem setRightBarButtonItem:finish];
}

- (void)actionCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.subject sendCompleted];
}

- (void)actionFinish:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.subject sendNext:self.image];
    [self.subject sendCompleted];
}

@end

