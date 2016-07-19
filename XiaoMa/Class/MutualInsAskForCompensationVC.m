//
//  MutualInsAskForCompensationVC.m
//  XiaoMa
//
//  Created by St.Jimmy on 5/27/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "MutualInsAskForCompensationVC.h"
#import "AskToCompensationOp.h"
#import "HKProgressView.h"
#import "CKLine.h"
#import "MutualInsScencePageVC.h"
#import "NSString+RectSize.h"
#import "UIImage+Utilities.h"
#import "HKTimer.h"
#import "HKImageAlertVC.h"
#import "HKMessageAlertVC.h"
#import "MutualInsAcceptCompensationVC.h"
#import "ConfirmClaimOp.h"
#import "MutualInsPicListVC.h"

#define StamperImageWidthHeight 120

@interface MutualInsAskForCompensationVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSString *bankCardDescription;
@property (nonatomic, strong) CKList *dataSource;
@property (nonatomic, copy) NSArray *fetchedDataSource;

@property (nonatomic, nonnull,strong)UIImage * stamperImage;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *newbieGuideBarButtonItem;

@end

@implementation MutualInsAskForCompensationVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    NSLog(@"MutualInsAskForCompensationVC deallocated");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (IOSVersionGreaterThanOrEqualTo(@"8.0")) {
        self.tableView.estimatedRowHeight = 136;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    // 下拉刷新设置
    [self setupRefreshView];
    
    [self setupNewbieGuideBarButtonItem];
    
    // 进入页面后获取所有数据
    [self fetchAllData];
    
    // 监听 kNotifyUpdateClaimList 时间判断是否需要更新页面
    @weakify(self)
    [self listenNotificationByName:kNotifyUpdateClaimList withNotifyBlock:^(NSNotification *note, id weakSelf) {
        
        @strongify(self)
        [self fetchAllData];
    }];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(setBackAction)];
}

/// 下拉刷新设置
- (void)setupRefreshView
{
    @weakify(self);
    [[self.tableView.refreshView rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        @strongify(self);
        [self fetchAllData];
    }];
}

/// navigationBar 上「新手指南」按钮的图标设置
- (void)setupNewbieGuideBarButtonItem
{
    // 从 NSUserDefaults 中取 isPressed 的 Bool 值，判断是否点击过
    BOOL isPressed = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isPressed"] boolValue];
    
    // 如有获取到 isPressed 值，则正常显示「新手指南」图标。反之则为没有点按过，让「新手指南」图标附上红点
    self.newbieGuideBarButtonItem.image = isPressed ? [[UIImage imageNamed:@"mutualIns_newbieGuideButtonNoRedDot_barButtonItem"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] : [[UIImage imageNamed:@"mutualIns_newbieGuideButtonWithRedDot_barButtonItem"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

#pragma mark - Action events
/// navigationBar 上「新手指南」的点击事件
- (IBAction)newbieGuideBarButtonClicked:(id)sender
{
    [MobClick event:@"woyaobuchang" attributes:@{@"woyaobuchang":@"woyaobuchang2"}];
    
    // 只要点按过「新手指南」图标，则让该图标变为不带红点状态
    self.newbieGuideBarButtonItem.image = [[UIImage imageNamed:@"mutualIns_newbieGuideButtonNoRedDot_barButtonItem"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 从 NSUserDefaults 中取 isPressed 的 Bool 值，判断是否点击过
    BOOL isPressed = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isPressed"] boolValue];
    
    // 如未获取到 isPressed 的值，则给 NSUserDefaults 存储一个 isPressed 值，表明用户已经按过该图标
    if (!isPressed) {
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isPressed"];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isFirstPressed"];
    
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.originVC = self;
    NSString * urlStr;
#if XMDDEnvironment==0
    urlStr = @"http://dev01.xiaomadada.com/apphtml/xinshouyindao.html";
#elif XMDDEnvironment==1
    urlStr = @"http://dev.xiaomadada.com/apphtml/xinshouyindao.html";
#else
    urlStr = @"http://www.xiaomadada.com/apphtml/xinshouyindao.html";
#endif
    
    vc.url = urlStr;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)serviceCallButtonClicked:(id)sender
{
    [MobClick event:@"woyaobuchang" attributes:@{@"woyaobuchang":@"woyaobuchang3"}];
    
    HKImageAlertVC *alert = [[HKImageAlertVC alloc] init];
    alert.topTitle = @"温馨提示";
    alert.imageName = @"mins_bulb";
    alert.message = @"快速报案可拨打客服电话：4007-111-111，是否立即拨打？";
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color: kGrayTextColor clickBlock:nil];
    HKAlertActionItem *dial = [HKAlertActionItem itemWithTitle:@" 拨打" color: HEXCOLOR(@"#F39C12") clickBlock:^(id alertVC) {
        [gPhoneHelper makePhone:@"4007111111"];
    }];
    alert.actionItems = @[cancel, dial];
    [alert show];
}

#pragma mark - Obtain data
/// 进入页面后获取所有数据
- (void)fetchAllData
{
    if ([LoginViewModel loginIfNeededForTargetViewController:self])
    {
        AskToCompensationOp *op = [[AskToCompensationOp alloc] init];
        
        @weakify(self);
        [[[op rac_postRequest] initially:^{
            @strongify(self);
            if (!self.fetchedDataSource.count)
            {
                // 防止有数据的时候，下拉刷新导致页面会闪一下
                CGFloat reducingY = self.view.frame.size.height * 0.1056;
                [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:CGPointMake(self.view.center.x, self.view.center.y - reducingY)];
                self.tableView.hidden = YES;
            }
        }] subscribeNext:^(AskToCompensationOp *rop) {
            
            @strongify(self);
            [self.view stopActivityAnimation];
            [self.tableView.refreshView endRefreshing];
            self.tableView.hidden = !(rop.claimList.count > 0);
            
            if (rop.claimList.count > 0)
            {
                [self.view hideDefaultEmptyView];
                
                self.tableView.hidden = NO;
                
                self.bankCardDescription = rop.bankNoDesc;
                // 记录请求到数据的时间
                for (NSDictionary *dict in rop.claimList) {
                    dict.customInfo = [[NSMutableDictionary alloc] init];
                    [dict.customInfo setObject:[NSDate date] forKey:@"timeTag"];
                }
            }
            else
            {
                [self.view showEmptyViewWithImageName:@"def_noCompensationRecord_imageView" text:@"暂无补偿记录" textColor:HEXCOLOR(@"#18D06A") centerOffset:-80 tapBlock:nil];
                self.tableView.hidden = YES;
            }
            self.fetchedDataSource = rop.claimList;
            [self setDataSource];
        } error:^(NSError *error) {
            
            @strongify(self);
            [self.tableView.refreshView endRefreshing];
            [self.view stopActivityAnimation];
            self.tableView.hidden = YES;
            [self.view showDefaultEmptyViewWithText:@"请求数据失败，请点击重试" tapBlock:^{
                [self.view hideDefaultEmptyView];
                [self  fetchAllData];
            }];
        }];
    }
}

/// 接受 / 拒绝补偿的请求方法
-(void)confirmClaimWithAgreement:(NSNumber *)agreement claimID:(NSNumber *)claimID andBankNo:(NSString *)bankcardNo
{
    ConfirmClaimOp *op = [[ConfirmClaimOp alloc]init];
    op.req_claimid = claimID;
    op.req_agreement = agreement;
    op.req_bankcardno = bankcardNo;
    
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        @strongify(self);
        [gToast showingWithText:@"" inView:self.view];
    }] subscribeNext:^(id x) {
        @strongify(self);
        [gToast dismissInView:self.view];
        
        [self postCustomNotificationName:kNotifyUpdateClaimList object:nil];
        
    } error:^(NSError *error) {
        @strongify(self);
        [gToast showError:error.domain inView:self.view];
    }];
}

/// 设置 CKList 的数据源，用于展示。
- (void)setDataSource
{
    self.dataSource = [CKList list];
    NSMutableArray *dataArray = [NSMutableArray new];
    for (NSDictionary *dict in self.fetchedDataSource) {
        
        NSInteger isFastClaimInt = [dict[@"isfastclaim"] integerValue];
        NSInteger status = [dict[@"status"] integerValue];
        NSArray *detailInfoArray = dict[@"detailinfo"];
        
        // 顶部进度条 Cell
        CKDict *progressCell = [self setupProgressViewCellWithStatus:status isFastClaimInteger:isFastClaimInt dictOfData:dict detailInfoArray:detailInfoArray];
        
        // 中间车牌号和状态标签显示 Cell
        CKDict *statusCell = [self setupStatusCellWithStatus:status isFastClaimInteger:isFastClaimInt dictOfData:dict detailInfoArray:detailInfoArray];
        
        // 信息详情显示 Cell
        CKDict *detailCell = [self setupDetailCellWithStatus:status isFastClaimInteger:isFastClaimInt dictOfData:dict detailInfoArray:detailInfoArray];
        
        // 提示语 Cell
        CKDict *tipsCell = [self setupTipsCellWithStatus:status isFastClaimInteger:isFastClaimInt dictOfData:dict detailInfoArray:detailInfoArray];
        
        // 拍照上传 / 重新拍照上传 Cell
        CKDict *takePhotoCell = [self setupTakePhotoCellWithStatus:status isFastClaimInteger:isFastClaimInt dictOfData:dict detailInfoArray:detailInfoArray];
        
        // 价格不满意 && 接受补偿 Cell
        CKDict *compensateOrDeclineCell = [self setupCompensateOrDeclineCellWithStatus:status isFastClaimInteger:isFastClaimInt dictOfData:dict detailInfoArray:detailInfoArray];
        
        // 补偿金额和作为底部提示语的 Cell
        CKDict *compensationPriceBottomCell = [self setupCompensationPriceBottomCellWithStatus:status isFastClaimInteger:isFastClaimInt dictOfData:dict detailInfoArray:detailInfoArray];
        
        
        
        // 通过各状态来拼接相应的 Cell
        // -1 为「待现场拍照」，如果为快速补偿状态下，则为「代查勘定损」
        if (status == -1) {
            CKList *waitingForPhoto = $(progressCell, statusCell);
            NSMutableArray *detailCellArray = [NSMutableArray new];
            int a;
            for (a = 0; a < detailInfoArray.count; a++) {
                [detailCellArray addObject:detailCell];
            }
            [waitingForPhoto addObjectsFromArray:detailCellArray];
            
            // 通过是否为快速补偿来判断拼接相应的 Cell
            if (isFastClaimInt == 0) {
                NSArray *remainingCell = @[compensationPriceBottomCell];
                [waitingForPhoto addObjectsFromArray:remainingCell];
                [dataArray addObject:waitingForPhoto];
            } else {
                NSArray *remainingCell = @[tipsCell, takePhotoCell];
                [waitingForPhoto addObjectsFromArray:remainingCell];
                [dataArray addObject:waitingForPhoto];
            }
        }
        
        // 0 为「已拍照，审核中」
        if ([dict[@"status"] integerValue] == 0) {
            CKList *photoTook = $(progressCell, statusCell);
            NSMutableArray *detailCellArray = [NSMutableArray new];
            int a;
            for (a = 0; a < detailInfoArray.count; a++) {
                [detailCellArray addObject:detailCell];
            }
            [photoTook addObjectsFromArray:detailCellArray];
            NSArray *remainingCell = @[compensationPriceBottomCell];
            [photoTook addObjectsFromArray:remainingCell];
            [dataArray addObject:photoTook];
        }
        
        // 1 为「待补偿确认」
        if ([dict[@"status"] integerValue] == 1) {
            CKList *compensatedToConfirm = $(progressCell, statusCell);
            NSMutableArray *detailCellArray = [NSMutableArray new];
            int a;
            for (a = 0; a < detailInfoArray.count; a++) {
                [detailCellArray addObject:detailCell];
            }
            [compensatedToConfirm addObjectsFromArray:detailCellArray];
            NSArray *remainingCell = @[tipsCell, compensateOrDeclineCell];
            [compensatedToConfirm addObjectsFromArray:remainingCell];
            [dataArray addObject:compensatedToConfirm];
        }
        
        // 2 为「打款中 / 理赔中」
        if ([dict[@"status"] integerValue] == 2) {
            CKList *compensating = $(progressCell, statusCell);
            NSMutableArray *detailCellArray = [NSMutableArray new];
            int a;
            for (a = 0; a < detailInfoArray.count; a++) {
                [detailCellArray addObject:detailCell];
            }
            [compensating addObjectsFromArray:detailCellArray];
            NSArray *remainingCell = @[compensationPriceBottomCell];
            [compensating addObjectsFromArray:remainingCell];
            [dataArray addObject:compensating];
        }
        
        // 3 为「补偿已结束」
        if ([dict[@"status"] integerValue] == 3) {
            CKList *compensationEnded = $(progressCell, statusCell);
            NSMutableArray *detailCellArray = [NSMutableArray new];
            int a;
            for (a = 0; a < detailInfoArray.count; a++) {
                [detailCellArray addObject:detailCell];
            }
            [compensationEnded addObjectsFromArray:detailCellArray];
            NSArray *remainingCell = @[compensationPriceBottomCell];
            [compensationEnded addObjectsFromArray:remainingCell];
            [dataArray addObject:compensationEnded];
        }
        
        // 4 为「需重新拍照]
        if ([dict[@"status"] integerValue] == 4) {
            CKList *needRetakePhoto = $(progressCell, statusCell);
            NSMutableArray *detailCellArray = [NSMutableArray new];
            int a;
            for (a = 0; a < detailInfoArray.count; a++) {
                [detailCellArray addObject:detailCell];
            }
            [needRetakePhoto addObjectsFromArray:detailCellArray];
            NSArray *remainingCell = @[tipsCell, takePhotoCell];
            [needRetakePhoto addObjectsFromArray:remainingCell];
            [dataArray addObject:needRetakePhoto];
        }
        
        // 5 为「拍照超时」
        if ([dict[@"status"] integerValue] == 5) {
            CKList *overtimeTaking = $(progressCell, statusCell);
            NSMutableArray *detailCellArray = [NSMutableArray new];
            int a;
            for (a = 0; a < detailInfoArray.count; a++) {
                [detailCellArray addObject:detailCell];
            }
            [overtimeTaking addObjectsFromArray:detailCellArray];
            NSArray *remainingCell = @[tipsCell, takePhotoCell];
            [overtimeTaking addObjectsFromArray:remainingCell];
            [dataArray addObject:overtimeTaking];
        }
        
        // 10 为「已拒绝 / 用户拒绝」
        if ([dict[@"status"] integerValue] == 10) {
            CKList *userDeclined = $(progressCell, statusCell);
            NSMutableArray *detailCellArray = [NSMutableArray new];
            int a;
            for (a = 0; a < detailInfoArray.count; a++) {
                [detailCellArray addObject:detailCell];
            }
            [userDeclined addObjectsFromArray:detailCellArray];
            NSArray *remainingCell = @[tipsCell];
            [userDeclined addObjectsFromArray:remainingCell];
            [dataArray addObject:userDeclined];
        }
        
        // 20 为「已拒绝 / 系统拒绝」
        if ([dict[@"status"] integerValue] == 20) {
            CKList *systemDeclined = $(progressCell, statusCell);
            NSMutableArray *detailCellArray = [NSMutableArray new];
            int a;
            for (a = 0; a < detailInfoArray.count; a++) {
                [detailCellArray addObject:detailCell];
            }
            [systemDeclined addObjectsFromArray:detailCellArray];
            NSArray *remainingCell = @[compensationPriceBottomCell];
            [systemDeclined addObjectsFromArray:remainingCell];
            [dataArray addObject:systemDeclined];
        }
    }
    
    // 将拼接好的 Cell 逐一添加到 CKList 的 dataSource 中
    self.dataSource = [CKList listWithArray:dataArray];
    
    //    self.dataSource = $($(progressCell, statusCell, detailCell, detailCell, detailCell, tipsCell, compensationPriceBottomCell));
    
    [self.tableView reloadData];
}

#pragma mark - The settings of Cells
/// 顶部进度条 Cell 的设置方法
- (CKDict *)setupProgressViewCellWithStatus:(NSInteger)status isFastClaimInteger:(NSInteger)isFastClaimInt dictOfData:(NSDictionary *)dict detailInfoArray:(NSArray *)detailInfoArray
{
    @weakify(self);
    CKDict *progressCell = [CKDict dictWith:@{kCKItemKey: @"progressCell", kCKCellID: @"ProgressCell"}];
    progressCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 48;
    });
    progressCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        HKProgressView *progressView = (HKProgressView *)[cell.contentView viewWithTag:100];
        UIView *backgroundView = (UIView *)[cell.contentView viewWithTag:101];
        CKLine *leftLine = (CKLine *)[cell.contentView viewWithTag:102];
        CKLine *rightLine = (CKLine *)[cell.contentView viewWithTag:103];
        UIView *fillingView = (UIView *)[cell.contentView viewWithTag:104];
        [cell.contentView bringSubviewToFront:fillingView];
        rightLine.lineColor = kLightLineColor;
        rightLine.linePixelWidth = 1;
        rightLine.lineAlignment = CKLineAlignmentVerticalRight;
        leftLine.lineColor = kLightLineColor;
        leftLine.linePixelWidth = 1;
        leftLine.lineAlignment = CKLineAlignmentVerticalLeft;
        [cell.contentView bringSubviewToFront:leftLine];
        [cell.contentView bringSubviewToFront:rightLine];
        
        progressView.normalColor = kBackgroundColor;
        progressView.normalTextColor = HEXCOLOR(@"#BCBCBC");
        
        // 通过 isfastclaim 的值决定 progressView.titleArray 的个数
        if (isFastClaimInt == 1) {
            progressView.titleArray = @[@"补偿定价", @"补偿确认", @"补偿结束"];
        } else {
            progressView.titleArray = @[@"补偿定价", @"补偿结束"];
        }
        
        NSInteger index = [self indexOfProgressViewFromFetchedStatus:status fastClaimNo:isFastClaimInt];
        
        progressView.selectedIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, index)];
        
        backgroundView.layer.borderColor = HEXCOLOR(@"#dedfe0").CGColor;
        backgroundView.layer.borderWidth = 0.5;
        backgroundView.layer.masksToBounds = YES;
        
        cell.layer.masksToBounds = YES;
    });
    
    return progressCell;
}

/// 中间车牌号和状态标签显示 Cell 的设置方法
- (CKDict *)setupStatusCellWithStatus:(NSInteger)status isFastClaimInteger:(NSInteger)isFastClaimInt dictOfData:(NSDictionary *)dict detailInfoArray:(NSArray *)detailInfoArray
{
    @weakify(self);
    CKDict *statusCell = [CKDict dictWith:@{kCKItemKey: @"statusCell", kCKCellID: @"StatusCell"}];
    statusCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 34;
    });
    statusCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UIView *statusTagView = (UIView *)[cell.contentView viewWithTag:106];
        UILabel *carNumberLabel = (UILabel *)[cell.contentView viewWithTag:100];
        UIImageView *statusImageView = (UIImageView *)[cell.contentView viewWithTag:101];
        UIImageView *stamperImageView = (UIImageView *)[cell.contentView viewWithTag:105];
        UILabel *statusLabel = (UILabel *)[cell.contentView viewWithTag:102];
        CKLine *leftLine = (CKLine *)[cell.contentView viewWithTag:103];
        CKLine *rightLine = (CKLine *)[cell.contentView viewWithTag:104];
        
        rightLine.lineColor = kLightLineColor;
        rightLine.linePixelWidth = 1;
        rightLine.lineAlignment = CKLineAlignmentVerticalRight;
        leftLine.lineColor = kLightLineColor;
        leftLine.linePixelWidth = 1;
        leftLine.lineAlignment = CKLineAlignmentVerticalLeft;
        
        carNumberLabel.text = dict[@"licensenum"];
        
        if (isFastClaimInt == 1) {
            stamperImageView.hidden = NO;
            
            if (dict.customObject && [dict.customObject isKindOfClass:[UIImage class]])
            {
                stamperImageView.image = dict.customObject;
            }
            else
            {
                UIImage * cuttedImage = [self.stamperImage croppedImage:CGRectMake(0, 0, StamperImageWidthHeight, 16)];
                dict.customObject = cuttedImage;
                stamperImageView.image = dict.customObject;
            }
        } else {
            stamperImageView.hidden = YES;
        }
        
        [cell.contentView bringSubviewToFront:stamperImageView];
        
        NSString *imageName;
        if ((status == -1 && isFastClaimInt == 1) || status == 4 || status == 1 || status == 5) {
            imageName = @"common_statusTagRed_imageView";
        } else if (status == 0 || status == 2 || status == 10 || status == 20 || (status == -1 && isFastClaimInt == 0)) {
            imageName = @"common_statusTagOrange_imageView";
        } else {
            imageName = @"common_statusTagGreen_imageView";
        }
        UIImage *image = [UIImage imageNamed:imageName];
        image = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:0];
        statusImageView.image = image;
        
        statusLabel.text = dict[@"statusdesc"];
        
        [cell.contentView bringSubviewToFront:statusTagView];
        cell.clipsToBounds = NO;
        cell.contentView.clipsToBounds = NO;
    });
    
    return statusCell;
}

/// 信息详情显示 Cell 的设置方法
- (CKDict *)setupDetailCellWithStatus:(NSInteger)status isFastClaimInteger:(NSInteger)isFastClaimInt dictOfData:(NSDictionary *)dict detailInfoArray:(NSArray *)detailInfoArray
{
    @weakify(self);
    CKDict *detailCell = [CKDict dictWith:@{kCKItemKey: @"detailCell", kCKCellID: @"DetailCell"}];
    detailCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        
        NSDictionary *dict = detailInfoArray[indexPath.row - 2];
        NSString * content = dict[[[dict allKeys] safetyObjectAtIndex:0]];
        NSString * title = [[dict allKeys] safetyObjectAtIndex:0];
        
        CGFloat height = [self heightOfDetailCell:content title:title];
        
        return ceil(height);
    });
    detailCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:100];
        UILabel *descriptionLabel = (UILabel *)[cell.contentView viewWithTag:101];
        CKLine *leftLine = (CKLine *)[cell.contentView viewWithTag:102];
        CKLine *rightLine = (CKLine *)[cell.contentView viewWithTag:103];
        UIImageView *stamperImageView = (UIImageView *)[cell.contentView viewWithTag:105];
        
        leftLine.lineColor = kLightLineColor;
        leftLine.linePixelWidth = 1;
        leftLine.lineAlignment = CKLineAlignmentVerticalLeft;
        rightLine.lineColor = kLightLineColor;
        rightLine.linePixelWidth = 1;
        rightLine.lineAlignment = CKLineAlignmentVerticalRight;
        
        NSDictionary *dict = [detailInfoArray safetyObjectAtIndex:indexPath.row - 2];
        NSString * title = [[dict allKeys] safetyObjectAtIndex:0];
        NSString * content = dict[title];
        
        titleLabel.text = title;
        descriptionLabel.text = content;
        
        if (isFastClaimInt == 1) {
            stamperImageView.hidden = NO;
            
            if (dict.customObject && [dict.customObject isKindOfClass:[UIImage class]])
            {
                stamperImageView.image = dict.customObject;
            }
            else
            {
                
                CGFloat offsetY = 16;
                for (NSInteger i = 0;i < indexPath.row - 2;i++)
                {
                    NSDictionary *eachDict = [detailInfoArray safetyObjectAtIndex:i];
                    NSString * eachContent = eachDict[[[eachDict allKeys] safetyObjectAtIndex:0]];
                    NSString * eachTitle = [[eachDict allKeys] safetyObjectAtIndex:0];
                    
                    CGFloat height = [self heightOfDetailCell:eachContent title:eachTitle];
                    offsetY = offsetY + height;
                }
                
                if (offsetY >= StamperImageWidthHeight)
                {
                    stamperImageView.hidden = YES;
                }
                else
                {
                    CGFloat height = [self heightOfDetailCell:content title:title];
                    UIImage * cuttedImage = [self.stamperImage croppedImage:CGRectMake(0, offsetY, StamperImageWidthHeight, height)];
                    dict.customObject = cuttedImage;
                    stamperImageView.image = dict.customObject;
                    stamperImageView.hidden = NO;
                }
            }
        }
        else
        {
            stamperImageView.hidden = YES;
        }
    });
    
    return detailCell;
}

/// 提示语 Cell 的设置方法
- (CKDict *)setupTipsCellWithStatus:(NSInteger)status isFastClaimInteger:(NSInteger)isFastClaimInt dictOfData:(NSDictionary *)dict detailInfoArray:(NSArray *)detailInfoArray
{
    @weakify(self);
    CKDict *tipsCell = [CKDict dictWith:@{kCKItemKey: @"tipsCell", kCKCellID: @"TipsCell"}];
    tipsCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        NSString *title = dict[@"detailstatusdesc"];
        CGSize titleSize = [title labelSizeWithWidth:self.tableView.frame.size.width - 16 font:[UIFont systemFontOfSize:11]];
        
        CGFloat height = titleSize.height + 15;
        height = MAX(height, 36);
        return height;
    });
    tipsCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UILabel *tipsLabel = (UILabel *)[cell.contentView viewWithTag:100];
        CKLine *leftLine = (CKLine *)[cell.contentView viewWithTag:101];
        CKLine *rightLine = (CKLine *)[cell.contentView viewWithTag:102];
        
        leftLine.lineColor = kLightLineColor;
        leftLine.linePixelWidth = 1;
        leftLine.lineAlignment = CKLineAlignmentVerticalLeft;
        rightLine.lineColor = kLightLineColor;
        rightLine.linePixelWidth = 1;
        rightLine.lineAlignment = CKLineAlignmentVerticalRight;
        
        // 通过状态来判断字体颜色和大小
        if ((status == -1 && isFastClaimInt == 1) || status == 4 || status == 1 || status == 5) {
            tipsLabel.textColor = HEXCOLOR(@"#D02C47");
            tipsLabel.font = [UIFont systemFontOfSize:11];
            
            if (status == 1) {
                tipsLabel.font = [UIFont systemFontOfSize:17];
            }
        } else if (status == 0 || status == 2 || status == 10 || status == 20 || (status == -1 && isFastClaimInt == 0)) {
            tipsLabel.textColor = HEXCOLOR(@"#E87131");
            tipsLabel.font = [UIFont systemFontOfSize:11];
            
            if (status == 2) {
                tipsLabel.font = [UIFont systemFontOfSize:17];
            }
        } else {
            tipsLabel.textColor = HEXCOLOR(@"#18D06A");
            tipsLabel.font = [UIFont systemFontOfSize:17];
        }
        
        if (status == -1) {
            NSTimeInterval leftTimeInterval = [dict[@"lefttime"] integerValue] / 1000;
            if (leftTimeInterval <= 0) {
                
            } else {
                NSDate *recordedDate;
                
                if (dict.customInfo) {
                    recordedDate = dict.customInfo[@"timeTag"];
                } else {
                    [NSDate date];
                }
                
                NSDate *currentDate = [NSDate date];
                
                NSTimeInterval endingTimeInterval = [recordedDate timeIntervalSince1970] + leftTimeInterval;
                NSTimeInterval currentTimeInterval = [currentDate timeIntervalSince1970];
                
                NSTimeInterval spacingTimeInterval = endingTimeInterval - currentTimeInterval;
                
                if (spacingTimeInterval > 0) {
                    NSString *titleString = dict[@"detailstatusdesc"];
                    NSString *timeString = [HKTimer ddhhmmFormatWithTimeInterval:spacingTimeInterval];
                    tipsLabel.text = [titleString stringByAppendingString:timeString];
                    
                    @weakify(self);
                    [[[HKTimer rac_timeCountDownWithOrigin:endingTimeInterval andTimeTag:0] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSString *timeString) {
                        @strongify(self);
                        NSString *countDownTitleString = dict[@"detailstatusdesc"];
                        if (![timeString isEqualToString:@"end"]) {
                            tipsLabel.text = [countDownTitleString stringByAppendingString:timeString];
                        } else {
                            
                            tipsLabel.text = [countDownTitleString stringByAppendingString:@"00:00:00"];
                            
                            /// 系统时间走的比服务器快，延迟 2s 刷新
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                
                                [self fetchAllData];
                            });
                        }
                    }];
                }
            }
        } else {
            tipsLabel.text = dict[@"detailstatusdesc"];
        }
    });
    
    return tipsCell;
}

/// 拍照上传 / 重新拍照上传 Cell 的设置方法
- (CKDict *)setupTakePhotoCellWithStatus:(NSInteger)status isFastClaimInteger:(NSInteger)isFastClaimInt dictOfData:(NSDictionary *)dict detailInfoArray:(NSArray *)detailInfoArray
{
    @weakify(self);
    CKDict *takePhotoCell = [CKDict dictWith:@{kCKItemKey: @"takePhotoCell", kCKCellID: @"TakePhotoCell"}];
    takePhotoCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 44;
    });
    takePhotoCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UIButton *takePhotoButton = (UIButton *)[cell.contentView viewWithTag:100];
        CKLine *leftLine = (CKLine *)[cell.contentView viewWithTag:101];
        CKLine *rightLine = (CKLine *)[cell.contentView viewWithTag:102];
        UIView *fillingView = (UIView *)[cell.contentView viewWithTag:103];
        
        leftLine.lineColor = kLightLineColor;
        leftLine.linePixelWidth = 1;
        leftLine.lineAlignment = CKLineAlignmentVerticalLeft;
        rightLine.lineColor = kLightLineColor;
        rightLine.linePixelWidth = 1;
        rightLine.lineAlignment = CKLineAlignmentVerticalRight;
        [cell.contentView bringSubviewToFront:leftLine];
        [cell.contentView bringSubviewToFront:rightLine];
        
        takePhotoButton.layer.borderColor = HEXCOLOR(@"#dedfe0").CGColor;
        takePhotoButton.layer.borderWidth = 0.5;
        takePhotoButton.layer.masksToBounds = YES;
        
        // 通过状态判定按钮为「重新拍照上传」还是「拍照上传」
        if (status == 4) {
            
            @weakify(self);
            [takePhotoButton setTitle:@"重新拍照上传" forState:UIControlStateNormal];
            [[[takePhotoButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                @strongify(self);
                
                [MobClick event:@"woyaobuchang" attributes:@{@"woyaobuchang":@"woyaobuchang6"}];
                
                MutualInsPicListVC * vc = [UIStoryboard vcWithId:@"MutualInsPicListVC" inStoryboard:@"MutualInsClaimsPicList"];
                vc.claimID = dict[@"claimid"];
                [self.navigationController pushViewController:vc animated:YES];
            }];
        } else {
            
            [takePhotoButton setTitle:@"拍照上传" forState:UIControlStateNormal];
            [[[takePhotoButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                @strongify(self);
                
                [MobClick event:@"woyaobuchang" attributes:@{@"woyaobuchang":@"woyaobuchang5"}];
                
                MutualInsScencePageVC *scencePageVC = [UIStoryboard vcWithId:@"MutualInsScencePageVC" inStoryboard:@"MutualInsClaims"];
                //                scencePageVC.noticeArr = self.tempArr;
                scencePageVC.claimid = dict[@"claimid"];
                [self.navigationController pushViewController:scencePageVC animated:YES];
            }];
        }
        
        // 通过状态判定按钮开关属性
        if (status == 5) {
            takePhotoButton.enabled = NO;
            cell.userInteractionEnabled = NO;
        } else {
            takePhotoButton.enabled = YES;
            cell.userInteractionEnabled = YES;
        }
    });
    
    return takePhotoCell;
}

/// 价格不满意 && 接受补偿 Cell 的设置方法
- (CKDict *)setupCompensateOrDeclineCellWithStatus:(NSInteger)status isFastClaimInteger:(NSInteger)isFastClaimInt dictOfData:(NSDictionary *)dict detailInfoArray:(NSArray *)detailInfoArray
{
    @weakify(self);
    CKDict *compensateOrDeclineCell = [CKDict dictWith:@{kCKItemKey: @"compensateOrDeclineCell", kCKCellID: @"CompensateOrDeclineCell"}];
    compensateOrDeclineCell[kCKCellPrepare] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 44;
    });
    compensateOrDeclineCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UIView *backgroundView = (UIView *)[cell.contentView viewWithTag:100];
        UIView *fillingView = (UIView *)[cell.contentView viewWithTag:105];
        UIButton *acceptCompensationButton = (UIButton *)[cell.contentView viewWithTag:101];
        UIButton *declineButton = (UIButton *)[cell.contentView viewWithTag:102];
        CKLine *leftLine = (CKLine *)[cell.contentView viewWithTag:103];
        CKLine *rightLine = (CKLine *)[cell.contentView viewWithTag:104];
        
        backgroundView.layer.cornerRadius = 5.0f;
        backgroundView.layer.borderColor = HEXCOLOR(@"#DEDFE0").CGColor;
        backgroundView.layer.borderWidth = 0.5;
        backgroundView.layer.masksToBounds = YES;
        
        [cell.contentView bringSubviewToFront:fillingView];
        
        leftLine.lineColor = kLightLineColor;
        leftLine.linePixelWidth = 1;
        leftLine.lineAlignment = CKLineAlignmentVerticalLeft;
        rightLine.lineColor = kLightLineColor;
        rightLine.linePixelWidth = 1;
        rightLine.lineAlignment = CKLineAlignmentVerticalRight;
        [cell.contentView bringSubviewToFront:leftLine];
        [cell.contentView bringSubviewToFront:rightLine];
        
        // 「接受补偿」按键的点击事件
        [[[acceptCompensationButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            [MobClick event:@"woyaobuchang" attributes:@{@"woyaobuchang":@"woyaobuchang8"}];
            
            MutualInsAcceptCompensationVC *acceptCompensationVC = [UIStoryboard vcWithId:@"MutualInsAcceptCompensationVC" inStoryboard:@"MutualInsClaims"];
            acceptCompensationVC.descriptionString = self.bankCardDescription;
            acceptCompensationVC.usernameString = dict[@"ownername"];
            acceptCompensationVC.claimID = dict[@"claimid"];
            acceptCompensationVC.fetchedBankCardNumber = dict[@"bankcardno"];
            [self.navigationController pushViewController:acceptCompensationVC animated:YES];
        }];
        
        // 「价格不满意」按钮的点击事件
        [[[declineButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            [MobClick event:@"woyaobuchang" attributes:@{@"woyaobuchang":@"woyaobuchang7"}];
            
            HKImageAlertVC *alert = [[HKImageAlertVC alloc] init];
            alert.topTitle = @"温馨提示";
            alert.message = @"如出现价格不满意等原因造成不愿意接受补偿，可进行拒绝补偿的操作，拒绝后客服会与您取得联系，并做进一步沟通";
            alert.imageName = @"mins_bulb";
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:^(id alertVC) {
                [MobClick event:@"woyaobuchang" attributes:@{@"woyaobuchang":@"woyaobuchang9"}];
            }];
            
            HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确认拒绝" color:kDefTintColor clickBlock:^(id alertVC) {
                [MobClick event:@"woyaobuchang" attributes:@{@"woyaobuchang":@"woyaobuchang10"}];
                [self confirmClaimWithAgreement:@(1) claimID:dict[@"claimid"] andBankNo:dict[@"bankcardno"]];
            }];
            alert.actionItems = @[cancel, confirm];
            [alert show];
        }];
    });
    
    return compensateOrDeclineCell;
}

/// 补偿金额和作为底部提示语的 Cell 的设置方法
- (CKDict *)setupCompensationPriceBottomCellWithStatus:(NSInteger)status isFastClaimInteger:(NSInteger)isFastClaimInt dictOfData:(NSDictionary *)dict detailInfoArray:(NSArray *)detailInfoArray
{
    @weakify(self);
    CKDict *compensationPriceBottomCell = [CKDict dictWith:@{kCKItemKey: @"compensationPriceBottomCell", kCKCellID: @"CompensationPriceBottomCell"}];
    compensationPriceBottomCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        NSString *title = dict[@"detailstatusdesc"];
        CGSize titleSize = [title labelSizeWithWidth:self.tableView.frame.size.width - 16 font:[UIFont systemFontOfSize:11]];
        
        CGFloat height = titleSize.height + 20;
        height = MAX(height, 40);
        return height;
    });
    compensationPriceBottomCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UIView *backgroundView = (UIView *)[cell.contentView viewWithTag:100];
        UIView *fillingView = (UIView *)[cell.contentView viewWithTag:104];
        UILabel *tipsLabel = (UILabel *)[cell.contentView viewWithTag:101];
        CKLine *leftLine = (CKLine *)[cell.contentView viewWithTag:102];
        CKLine *rightLine = (CKLine *)[cell.contentView viewWithTag:103];
        
        backgroundView.layer.cornerRadius = 5.0f;
        backgroundView.layer.borderColor = HEXCOLOR(@"#DEDFE0").CGColor;
        backgroundView.layer.borderWidth = 0.5;
        backgroundView.layer.masksToBounds = YES;
        
        [cell.contentView bringSubviewToFront:fillingView];
        
        leftLine.lineColor = kLightLineColor;
        leftLine.linePixelWidth = 1;
        leftLine.lineAlignment = CKLineAlignmentVerticalLeft;
        rightLine.lineColor = kLightLineColor;
        rightLine.linePixelWidth = 1;
        rightLine.lineAlignment = CKLineAlignmentVerticalRight;
        [cell.contentView bringSubviewToFront:leftLine];
        [cell.contentView bringSubviewToFront:rightLine];
        
        // 通过状态来判断字体颜色和大小
        if ((status == -1 && isFastClaimInt == 1) || status == 4 || status == 1 || status == 5) {
            tipsLabel.textColor = HEXCOLOR(@"#D02C47");
            tipsLabel.font = [UIFont systemFontOfSize:11];
            
            if (status == 1) {
                tipsLabel.font = [UIFont systemFontOfSize:17];
            }
        } else if (status == 0 || status == 2 || status == 10 || status == 20 || (status == -1 && isFastClaimInt == 0)) {
            tipsLabel.textColor = HEXCOLOR(@"#E87131");
            tipsLabel.font = [UIFont systemFontOfSize:11];
            
            if (status == 2) {
                tipsLabel.font = [UIFont systemFontOfSize:17];
            }
        } else {
            tipsLabel.textColor = HEXCOLOR(@"#18D06A");
            tipsLabel.font = [UIFont systemFontOfSize:17];
        }
        
        tipsLabel.text = dict[@"detailstatusdesc"];
    });
    
    return compensationPriceBottomCell;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CKList *cellList = self.dataSource[section];
    NSArray *countArray = [cellList allObjects];
    return countArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"woyaobuchang" attributes:@{@"woyaobuchang":@"woyaobuchang4"}];
    
    NSDictionary *dataDict = [self.fetchedDataSource safetyObjectAtIndex:indexPath.section];
    
    if ([dataDict[@"isfastclaim"] integerValue] == 1) {
        MutualInsPicListVC * vc = [UIStoryboard vcWithId:@"MutualInsPicListVC" inStoryboard:@"MutualInsClaimsPicList"];
        vc.claimID = dataDict[@"claimid"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 15;
    }
    
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    CKCellGetHeightBlock block = item[kCKCellGetHeight];
    
    if (block) {
        return block(item, indexPath);
    }
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item[kCKCellID] forIndexPath:indexPath];
    CKCellPrepareBlock block = item[kCKCellPrepare];
    
    if (block) {
        block(item, cell, indexPath);
    }
    
    return cell;
}

#pragma mark - Utilities
- (CGFloat)heightOfDetailCell:(NSString *)content title:(NSString *)title
{
    CGSize titleSize = [title labelSizeWithWidth:9999 font:[UIFont systemFontOfSize:14]];
    
    CGSize size = [content labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 6*2 - 10 - titleSize.width - 10 font:[UIFont systemFontOfSize:14]];
    CGFloat height = size.height + 12 + 2;
    height = MAX(height, 35);
    return height;
}

/// 通过该方法用 status 状态值来判断 progressView 的显示样式
- (NSInteger)indexOfProgressViewFromFetchedStatus:(NSInteger)status fastClaimNo:(NSInteger)fastClaimNo
{
    if (status <= 0 || status == 4 || (status == 2 && fastClaimNo == 0) || status == 5) {
        return 1;
    } else if (status == 1 || (fastClaimNo == 0 && status == 3) || (status == 2 && fastClaimNo == 1) || (fastClaimNo == 1 && status == 2)) {
        return 2;
    } else {
        return 3;
    }
    
    return 1;
}

#pragma mark - Lazy instantiation
- (UIImage *)stamperImage
{
    if (!_stamperImage)
    {
        _stamperImage = [[UIImage imageNamed:@"mutualIns_stamper_imageView"] scaleToSize:CGSizeMake(StamperImageWidthHeight,StamperImageWidthHeight)];
    }
    return _stamperImage;
}

-(void)setBackAction
{
    [MobClick event:@"woyaobuchang" attributes:@{@"woyaobuchang":@"woyaobuchang1"}];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
