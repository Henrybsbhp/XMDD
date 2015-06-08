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

@interface MyInfoViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic)NSInteger sex;
@property (nonatomic,strong)NSDate * birthday;
@property (nonatomic, strong) UIImage *avatar;

@property (weak, nonatomic) IBOutlet JTTableView *tableView;

@end

@implementation MyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!gAppMgr.myUser)
    {
                [self requestUserInfo];
    }
    else
    {
        //        [[gUserInfoMgr rac_getUserInfo:YES] subscribeNext:^(UserInfo * userInfo) {
        //
        //            [self.table reloadData];
        //        }];
    }
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
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
}

-(void)dealloc
{
    DebugLog(@"MyInfoViewController dealloc");
}

#pragma mark - Setup
- (void)setupSignals
{
    @weakify(self);
    RACDisposable *dis = [[[RACObserve(gAppMgr.myUser, avatarUrl) distinctUntilChanged] flattenMap:^RACStream *(id value) {
        
        return [gMediaMgr rac_getPictureForUrl:value withType:ImageURLTypeMedium defaultPic:nil errorPic:@"cm_avatar"];
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
    [[logoutBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
#pragma mark- warming
        [self logoutAction];
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
    
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"修改中…"];
    }] subscribeNext:^(UpdateUserInfoOp * op) {
        
        [gToast showSuccess:@"修改成功"];
        gAppMgr.myUser.sex = self.sex != 0 ? self.sex : gAppMgr.myUser.sex;
        gAppMgr.myUser.birthday = self.birthday ? self.birthday:gAppMgr.myUser.birthday;
        [self.tableView reloadData];

    } error:^(NSError *error) {
        [gToast showError:@"修改失败，再试一次"];
        [self.tableView reloadData];
    }];
}

- (void)requestUserInfo
{
    [[GetUserBaseInfoOp rac_fetchUserBaseInfo] subscribeNext:^(GetUserBaseInfoOp *op) {
        [self.tableView reloadData];
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AvaterCell" forIndexPath:indexPath];
        UIImageView *avaterImage = (UIImageView*)[cell viewWithTag:1];
        avaterImage.layer.cornerRadius = 25.0F;
        [avaterImage.layer setMasksToBounds:YES];

        [[RACObserve(self, avatar) takeUntilForCell:cell] subscribeNext:^(id x) {
            avaterImage.image = x;
        }];
        return cell;
    }
    else if (indexPath.row == 1)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NameCell" forIndexPath:indexPath];
        //姓名
        UILabel *nameLabel = (UILabel*)[cell viewWithTag:1];
        nameLabel.text = gAppMgr.myUser.userName;
        return cell;
    }
    else if (indexPath.row == 2)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SexCell" forIndexPath:indexPath];
        
        //性别
        UILabel *sexLabel = (UILabel*)[cell viewWithTag:1];
        if (gAppMgr.myUser.sex == 1)
        {
            sexLabel.text = @"男";
        }
        else if (gAppMgr.myUser.sex ==2)
        {
            sexLabel.text = @"女";
        }
        return cell;
    }
    else if (indexPath.row == 3)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BirthdayCell" forIndexPath:indexPath];
        //生日
        UILabel *birthLabel = (UILabel*)[cell viewWithTag:1];
        birthLabel.text = [gAppMgr.myUser.birthday dateFormatForYYMMdd];
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BindPhoneCell" forIndexPath:indexPath];
        //电话号码
        UILabel *phoneLabel = (UILabel*)[cell viewWithTag:1];
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
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        @weakify(self);
        [[gAppMgr.mediaMgr rac_pickPhotoInTargetVC:self inView:self.view initBlock:^(UIImagePickerController *picker) {
            
            picker.allowsEditing = YES;
        }] subscribeNext:^(id x) {
            
            @strongify(self);
            [self pickerAvatar:x];
        }];
    }
    else if (indexPath.row == 1)
    {
        EditMyInfoViewController * vc = [mineStoryboard instantiateViewControllerWithIdentifier:@"EditMyInfoViewController"];
        vc.naviTitle = @"修改昵称";
        vc.type = ModifyNickname;
        vc.content = gAppMgr.myUser.userName;
        vc.placeholder = @"请输入昵称";
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else if (indexPath.row == 2)
    {
        UIActionSheet * sexSheet = [[UIActionSheet alloc]initWithTitle:@"请选择性别" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男", @"女", nil];
        [sexSheet showInView:self.view];
        [[sexSheet rac_buttonClickedSignal] subscribeNext:^(NSNumber * number) {
            
            NSInteger btnIndex = [number integerValue];
            if (btnIndex == 2)
            {
                return ;
            }
            if (self.sex == btnIndex + 1)
                return; // 如果性别不变，则直接返回
            
            self.sex = MAX(MIN(2, (btnIndex + 1)), 1); // 控制一下性别的范围。
            [self requestModifyUserInfo:ModifySex];
        }];
        
    }
    else if (indexPath.row == 3)
    {
        [[DatePickerVC rac_presentPackerVCInView:self.navigationController.view withSelectedDate:self.birthday]
         subscribeNext:^(NSDate *date) {
             self.birthday = date;
             [self requestModifyUserInfo:ModifyBirthday];
         }];
    }
    else if (indexPath.row == 4)
    {
        if (!gAppMgr.myUser.phoneNumber.length)
        {
            //            EditMyInfoViewController * vc = [mineStoryboard instantiateViewControllerWithIdentifier:@"EditMyInfoViewController"];
            //            vc.naviTitle = @"修改手机";
            //            vc.type = ;
            //            vc.content = gAppMgr.myUser.userName;
            //            [self.navigationController pushViewController:vc animated:YES];        }
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 )
    {
        return 75.0;
    }
    else
    {
        return 44.0;
    }
}


#pragma mark - Private
- (void)pickerAvatar:(UIImage *)avatar
{
    UploadFileOp *op = [UploadFileOp new];
    op.req_fileType = @"jpg";
    [op setFileArray:@[avatar] withGetDataBlock:^NSData *(UIImage *img) {
        return UIImageJPEGRepresentation(img, 1.0);
    }];
    
    [[[[op rac_postRequest] flattenMap:^RACStream *(UploadFileOp *uploadOp) {
        UpdateUserInfoOp * op = [UpdateUserInfoOp operation];
        op.avatarUrl = [uploadOp.rsp_urlArray safetyObjectAtIndex:0];
        op.nickname = gAppMgr.myUser.userName;
        op.sex = gAppMgr.myUser.sex;
        op.birthday = gAppMgr.myUser.birthday;
        
        return [op rac_postRequest];
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
