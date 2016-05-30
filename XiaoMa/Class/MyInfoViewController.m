//
//  MyInfoViewController.m
//  XiaoMa
//
//  Created by jt on 15-5-11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MyInfoViewController.h"
#import "JTTableView.h"
#import "DatePickerVC.h"
#import "EditMyInfoViewController.h"
#import "UpdateUserInfoOp.h"
#import "GetUserBaseInfoOp.h"
#import "UIImage+Utilities.h"
#import "UploadFileOp.h"
#import "DownloadOp.h"
#import "HKImagePicker.h"
#import "HKTableViewCell.h"


@interface MyInfoViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic)NSInteger sex;
@property (nonatomic,strong)NSDate * birthday;
@property (nonatomic,strong) UIImage *avatar;

@property (weak, nonatomic) IBOutlet JTTableView *tableView;

@end

@implementation MyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self requestUserInfo];
    [self setupSignals];
    [self setupTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [gToast dismiss];
}

-(void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"MyInfoViewController dealloc");
}

#pragma mark - Setup
- (void)setupSignals
{
    @weakify(self);
    RACDisposable *dis = [[[RACObserve(gAppMgr.myUser, avatarUrl) distinctUntilChanged] flattenMap:^RACStream *(id value) {
        return [gMediaMgr rac_getImageByUrl:value withType:ImageURLTypeMedium defaultPic:nil errorPic:@"Common_Avatar_imageView"];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        self.avatar = x;
    }];
    [[self rac_deallocDisposable] addDisposable:dis];
}

- (void)setupTableView
{
    UIButton * logoutBtn = (UIButton *)[self.tableView.tableFooterView searchViewWithTag:20801];
    [logoutBtn.layer setMasksToBounds:YES];
    logoutBtn.layer.cornerRadius = 5.0f;
    
    @weakify(self);
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
        
        @strongify(self);
        [self logoutAction];
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"您确定要退出登录？" ActionItems:@[cancel,confirm]];
    
    [[logoutBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"rp302_6"];
        [alert show];
        
    }];
    
    [self.tableView reloadData];
}


#pragma mark - Action
- (void)navigationBackAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)logoutAction
{
    [HKLoginModel logout];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)requestModifyUserInfo:(ModifyType)type
{
    UpdateUserInfoOp * op = [UpdateUserInfoOp operation];
    if (type == ModifySex)
    {
        op.sex = self.sex;
        op.nickname = gAppMgr.myUser.userName;
        op.birthday = gAppMgr.myUser.birthday;
    }
    if (type == ModifyBirthday)
    {
        op.birthday = self.birthday;
        op.nickname = gAppMgr.myUser.userName;
        op.sex = gAppMgr.myUser.sex;
    }
    
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"修改中…"];
    }] subscribeNext:^(UpdateUserInfoOp * op) {
        
        @strongify(self);
        [gToast showSuccess:@"修改成功"];
        gAppMgr.myUser.sex = self.sex != 0 ? self.sex : gAppMgr.myUser.sex;
        gAppMgr.myUser.birthday = self.birthday ? self.birthday:gAppMgr.myUser.birthday;
        [self.tableView reloadData];
        
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        [self.tableView reloadData];
    }];
}

- (void)requestUserInfo
{
    @weakify(self);
    [[GetUserBaseInfoOp rac_fetchUserBaseInfo] subscribeNext:^(GetUserBaseInfoOp *op) {
        
        @strongify(self);
        [self.tableView reloadData];
    }];
}

- (void)removeSectionSeparatorInHKTableViewCell:(HKTableViewCell *)cell;
{
    if (!cell.currentIndexPath ||
        [cell.targetTableView numberOfRowsInSection:cell.currentIndexPath.section] > cell.currentIndexPath.row+1) {
        
    } else {
        
        [cell removeBorderLineWithAlignment:CKLineAlignmentHorizontalBottom];
        
    }
    
    if (cell.currentIndexPath.row == 0) {
        
        [cell removeBorderLineWithAlignment:CKLineAlignmentHorizontalTop];
        
    }
    else {
        [cell removeBorderLineWithAlignment:CKLineAlignmentHorizontalTop];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return 1;
        
    } else if (section == 1) {
        
        return 4;
        
    }
    
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"AvaterCell" forIndexPath:indexPath];
            HKTableViewCell *hkCell = (HKTableViewCell *)cell;
            UIImageView *avaterImage = (UIImageView*)[cell viewWithTag:1];
            avaterImage.layer.cornerRadius = 32.0F;
            [avaterImage.layer setMasksToBounds:YES];
            
            [[RACObserve(self, avatar) takeUntilForCell:hkCell] subscribeNext:^(id x) {
                avaterImage.image = x;
            }];
            
            return hkCell;
        }
        
    } else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            cell= [tableView dequeueReusableCellWithIdentifier:@"NameCell" forIndexPath:indexPath];
            HKTableViewCell *hkCell = (HKTableViewCell *)cell;
            //姓名
            UILabel *nameLabel = (UILabel*)[hkCell viewWithTag:1];
            nameLabel.text = gAppMgr.myUser.userName;
            
            [hkCell prepareCellForTableView:self.tableView atIndexPath:indexPath];
            
            [self removeSectionSeparatorInHKTableViewCell:hkCell];
            
            return hkCell;
            
        } else if (indexPath.row == 1) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"SexCell" forIndexPath:indexPath];
            HKTableViewCell *hkCell = (HKTableViewCell *)cell;
            //性别
            UILabel *sexLabel = (UILabel*)[hkCell viewWithTag:1];
            if (gAppMgr.myUser.sex == 1)
            {
                sexLabel.text = @"男";
            }
            else if (gAppMgr.myUser.sex == 2)
            {
                sexLabel.text = @"女";
            }
            
            [hkCell prepareCellForTableView:self.tableView atIndexPath:indexPath];
            
            [self removeSectionSeparatorInHKTableViewCell:hkCell];
            
            return hkCell;
            
        } else if (indexPath.row == 2) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"BirthdayCell" forIndexPath:indexPath];
            HKTableViewCell *hkCell = (HKTableViewCell *)cell;
            //生日
            UILabel *birthLabel = (UILabel*)[hkCell viewWithTag:1];
            birthLabel.text = [gAppMgr.myUser.birthday dateFormatForYYMMdd];
            
            [hkCell prepareCellForTableView:self.tableView atIndexPath:indexPath];
            
            [self removeSectionSeparatorInHKTableViewCell:hkCell];
            
            return hkCell;
            
        } else {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"BindPhoneCell" forIndexPath:indexPath];
            HKTableViewCell *hkCell = (HKTableViewCell *)cell;
            //电话号码
            UILabel *phoneLabel = (UILabel*)[hkCell viewWithTag:1];
            phoneLabel.text = gAppMgr.myUser.phoneNumber;
            
            UIView *arrowView = [cell viewWithTag:2];
            if (gAppMgr.myUser.phoneNumber.length)
            {
                arrowView.hidden = YES;
            }
            else
            {
                arrowView.hidden = NO;
            }
            
            return hkCell;
        }
        
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            [MobClick event:@"rp302_1"];
            HKImagePicker *picker = [HKImagePicker imagePicker];
            picker.allowsEditing = YES;
            picker.shouldShowBigImage = NO;
            @weakify(self);
            [[picker rac_pickImageInTargetVC:self inView:self.navigationController.view] subscribeNext:^(id x) {
                
                @strongify(self);
                [self pickerAvatar:x];
            }];
        }
        
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            
            [MobClick event:@"rp302_2"];
            EditMyInfoViewController * vc = [mineStoryboard instantiateViewControllerWithIdentifier:@"EditMyInfoViewController"];
            vc.naviTitle = @"修改昵称";
            vc.type = ModifyNickname;
            vc.content = gAppMgr.myUser.userName;
            vc.placeholder = @"请输入昵称";
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        else if (indexPath.row == 1)
        {
            [MobClick event:@"rp302_3"];
            UIActionSheet * sexSheet = [[UIActionSheet alloc]initWithTitle:@"请选择性别" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男", @"女", nil];
            [sexSheet showInView:self.view];
            @weakify(self);
            [[sexSheet rac_buttonClickedSignal] subscribeNext:^(NSNumber * number) {
                
                @strongify(self);
                NSInteger btnIndex = [number integerValue];
                if (btnIndex == 2) {
                    return ;
                }
                if (self.sex == btnIndex + 1)
                    return; // 如果性别不变，则直接返回
                
                self.sex = MAX(MIN(2, (btnIndex + 1)), 1); // 控制一下性别的范围。
                [self requestModifyUserInfo:ModifySex];
            }];
            
        }
        else if (indexPath.row == 2)
        {
            
            [MobClick event:@"rp302_4"];
            @weakify(self);
            [[DatePickerVC rac_presentPickerVCInView:self.navigationController.view withSelectedDate:self.birthday]
             subscribeNext:^(NSDate *date) {
                 
                 @strongify(self);
                 self.birthday = date;
                 [self requestModifyUserInfo:ModifyBirthday];
             }];
            
        }
        else if (indexPath.row == 3)
        {
            
            [MobClick event:@"rp302_5"];
            if (!gAppMgr.myUser.phoneNumber.length) {
                //            EditMyInfoViewController * vc = [mineStoryboard       instantiateViewControllerWithIdentifier:@"EditMyInfoViewController"];
                //            vc.naviTitle = @"修改手机";
                //            vc.type = ;
                //            vc.content = gAppMgr.myUser.userName;
                //            [self.navigationController pushViewController:vc animated:YES];        }
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            return 90;
        }
        
    }
    
    return 48;
}


#pragma mark - Private
- (void)pickerAvatar:(UIImage *)avatar
{
    UploadFileOp *op = [UploadFileOp new];
    op.req_fileExtType = @"jpg";
    [op setFileArray:@[avatar] withGetDataBlock:^NSData *(UIImage *img) {
        return UIImageJPEGRepresentation(img, 1.0);
    }];
    
    [[[[[op rac_postRequest] flattenMap:^RACStream *(UploadFileOp *uploadOp) {
        UpdateUserInfoOp * op = [UpdateUserInfoOp operation];
        op.avatarUrl = [uploadOp.rsp_urlArray safetyObjectAtIndex:0];
        op.nickname = gAppMgr.myUser.userName;
        op.sex = gAppMgr.myUser.sex;
        op.birthday = gAppMgr.myUser.birthday;
        
        return [op rac_postRequest];
    }] catch:^RACSignal *(NSError *error) {
        
        NSError * err = error;
        return [RACSignal error:err];
    }] initially:^{
        
        [gToast showingWithText:@"正在上传..."];
    }] subscribeNext:^(UpdateUserInfoOp * op) {
        
        [gToast dismiss];
        gAppMgr.myUser.avatarUrl = op.avatarUrl;
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

@end
