//
//  ViolationCommissionStateVC.m
//  XMDD
//
//  Created by St.Jimmy on 8/5/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "ViolationCommissionStateVC.h"
#import "GetViolationCommissionStateOp.h"
#import "CancelViolationCommissionOp.h"
#import "HKProgressView.h"
#import "NSString+RectSize.h"
#import "ViolationCommissionStateModel.h"
#import "SDPhotoBrowser.h"

@interface ViolationCommissionStateVC () <UITableViewDelegate, UITableViewDataSource, SDPhotoBrowserDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) CKList *dataSource;

@property (nonatomic, strong) UITableViewCell *proofCell;

@property (nonatomic, strong) UIImage *proofImage;

@property (nonatomic, copy) NSString *proofImageURL;

@end

@implementation ViolationCommissionStateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSDictionary *orderInfo1 = @{@"订单时间" : @"2016.06.06 12:32"};
    NSDictionary *orderInfo2 = @{@"违章罚款" : @"￥200.00"};
    NSDictionary *orderInfo3 = @{@"手续费" : @"￥30.00"};
    NSDictionary *orderInfo4 = @{@"支付时间" : @"2016.06.06 12:32"};
    NSDictionary *orderInfo5 = @{@"支付金额" : @"￥230.00"};
    NSDictionary *orderInfo6 = @{@"完成时间" : @"2016.06.06 12:32"};
    NSArray *array = @[orderInfo1, orderInfo2, orderInfo3, orderInfo4, orderInfo5, orderInfo6];
    NSDictionary *data = @{@"licensenumber" : @"皖H16712",
                           @"area" : @"超级大傻逼",
                           @"act" : @"不小心把自己吃了",
                           @"status" : @(3),
                           @"tip" : @"操你大爷",
                           @"orderinfo" : array};
    
    ViolationCommissionStateModel *model = [ViolationCommissionStateModel listWithJSONResponse:data];
    [self setDataSourceWithFetchedData:model];
//    [self fetchStateData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
/// 支付按钮
- (void)actionPay:(UIButton *)sender
{
    
}

/// 放弃按钮
- (void)actionAbandon:(UIButton *)sender
{
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kDefTintColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确认放弃" color:kDefTintColor clickBlock:^(id alertVC) {
        CancelViolationCommissionOp *op = [CancelViolationCommissionOp operation];
        op.recordID = self.recordID;
        @weakify(self);
        [[[op rac_postRequest] initially:^{
            [gToast showingWithText:nil];
        }] subscribeNext:^(id x) {
            @strongify(self);
            [gToast showSuccess:@"取消代办成功"];
            [self.navigationController popViewControllerAnimated:YES];
        } error:^(NSError *error) {
            [gToast showMistake:error.domain];
        }];
        
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"请确认是否放弃代办？" ActionItems:@[cancel, confirm]];
    [alert show];
}

/// 联系客服
- (IBAction)actionCallService:(id)sender
{
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
        [gPhoneHelper makePhone:@"4007111111"];
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"客服电话: 4007-111-111" ActionItems:@[cancel,confirm]];
    [alert show];
}

#pragma mark - fetch data
- (void)fetchStateData
{
    GetViolationCommissionStateOp *op = [GetViolationCommissionStateOp operation];
    op.recordID = self.recordID;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        @strongify(self);
        if (!self.dataSource.count) {
            
            CGFloat reducingY = self.view.frame.size.height * 0.1056;
            [self.view hideDefaultEmptyView];
            [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:CGPointMake(self.view.center.x, self.view.center.y - reducingY)];
            self.tableView.hidden = YES;
            
        } else {
            [self.tableView.refreshView beginRefreshing];
            self.tableView.hidden = NO;
        }
        
    }] subscribeNext:^(GetViolationCommissionStateOp *rop) {
        @strongify(self);
        if (rop.vcSateModel) {
            self.tableView.hidden = NO;
            [self setDataSourceWithFetchedData:rop.vcSateModel];
        } else {
            self.tableView.hidden = YES;
            [self.view showDefaultEmptyViewWithText:@"暂无代办状态"];
        }
        
        [self.view stopActivityAnimation];
        
    } error:^(NSError *error) {
        @strongify(self);
        [self.view stopActivityAnimation];
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"获取信息失败，请点击重试" tapBlock:^{
            [self fetchStateData];
        }];
    }];
}

- (void)setDataSourceWithFetchedData:(ViolationCommissionStateModel *)model
{
    self.dataSource = [CKList list];
    
    if (model.status == XMVCommissionWaiting) {
        
        [self.dataSource addObject:$([self setupProgressViewCellWithIndex:1], [self setupCarDescCellWithModel:model], [self setupTipsCellWithModel:model]) forKey:nil];
        
    } else if (model.status == XMVCommissionPayWaiting) {
        
        NSMutableArray *cellArray = [NSMutableArray array];
        for (NSDictionary *dict in model.orderInfo) {
            CKDict *commissionListCell = [self setupCommissionListCellWithDict:dict];
            [cellArray addObject:commissionListCell];
        }
        [self.dataSource addObject:$([self setupProgressViewCellWithIndex:2], [self setupCarDescCellWithModel:model], [self setupCommissionTitleCell], [self setupBlankCell], CKJoin(cellArray), [self setupBlankCell], [self setupTipsCellWithModel:model], [self setupPayCellWithModel:model]) forKey:nil];
        
    } else if (model.status == XMVCommissionProcessing) {
        
        NSMutableArray *cellArray = [NSMutableArray array];
        for (NSDictionary *dict in model.orderInfo) {
            CKDict *commissionListCell = [self setupCommissionListCellWithDict:dict];
            [cellArray addObject:commissionListCell];
        }
        [self.dataSource addObject:$([self setupProgressViewCellWithIndex:3], [self setupCarDescCellWithModel:model], [self setupCommissionTitleCell], [self setupBlankCell], CKJoin(cellArray), [self setupBlankCell], [self setupTipsCellWithModel:model]) forKey:nil];
        
    } else if (model.status == XMVCommissionComplete) {
        
        NSMutableArray *cellArray = [NSMutableArray array];
        for (NSDictionary *dict in model.orderInfo) {
            CKDict *commissionListCell = [self setupCommissionListCellWithDict:dict];
            [cellArray addObject:commissionListCell];
        }
        [self.dataSource addObject:$([self setupProgressViewCellWithIndex:4], [self setupCarDescCellWithModel:model], [self setupCommissionTitleCell], [self setupBlankCell], CKJoin(cellArray), [self setupBlankCell], [self setupTipsCellWithModel:model], [self setupProofCellWithModel:model]) forKey:nil];
        
    } else if (model.status == XMVCommissionReviewFailed) {
        
        [self.dataSource addObject:$([self setupFailedCellWithStatus:XMVCommissionReviewFailed], [self setupCarDescCellWithModel:model], [self setupTipsCellWithModel:model]) forKey:nil];
        
    } else {
        
        [self.dataSource addObject:$([self setupFailedCellWithStatus:model.status], [self setupCarDescCellWithModel:model], [self setupTipsCellWithModel:model]) forKey:nil];
        
    }
    
    [self.tableView reloadData];
}

#pragma mark - The settings of Cells
- (CKDict *)setupProgressViewCellWithIndex:(CGFloat)index
{
    CKDict *progressCell = [CKDict dictWith:@{kCKItemKey: @"progressCell", kCKCellID: @"ProgressCell"}];
    progressCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 48;
    });
    
    progressCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        HKProgressView *progressView = (HKProgressView *)[cell.contentView viewWithTag:100];
        progressView.normalColor = kBackgroundColor;
        progressView.normalTextColor = HEXCOLOR(@"#BCBCBC");
        progressView.titleArray = @[@"等待受理", @"付款", @"代办中", @"完成"];
        progressView.selectedIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, index)];
    });
    
    return progressCell;
}

- (CKDict *)setupCarDescCellWithModel:(ViolationCommissionStateModel *)model
{
    CKDict *carDescCell = [CKDict dictWith:@{kCKItemKey: @"carDescCell", kCKCellID: @"CarDescCell"}];
    carDescCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        NSString *locationString = model.area;
        NSString *descString = model.act;
        
        CGSize locationSize = [locationString labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 38 font:[UIFont systemFontOfSize:13]];
        CGSize descSize = [descString labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 20 font:[UIFont systemFontOfSize:14]];
        
        CGFloat height = locationSize.height + descSize.height + 55;
        
        return MAX(height, 87);
    });
    
    carDescCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *carNumLabel = (UILabel *)[cell.contentView viewWithTag:100];
        UILabel *locationLabel = (UILabel *)[cell.contentView viewWithTag:101];
        UILabel *descLabel = (UILabel *)[cell.contentView viewWithTag:102];
        
        carNumLabel.text = model.licenseNumber;
        locationLabel.text = model.area;
        descLabel.text = model.act;
    });
    
    return carDescCell;
}

- (CKDict *)setupTipsCellWithModel:(ViolationCommissionStateModel *)model
{
    CKDict *tipsCell = [CKDict dictWith:@{kCKItemKey: @"tipsCell", kCKCellID: @"TipsCell"}];
    tipsCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        CGSize tipsSize = [model.tips labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 20 font:[UIFont systemFontOfSize:13]];
        CGFloat height = tipsSize.height + 28;
        
        return MAX(height, 49);
    });
    
    tipsCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *tipsLabel = (UILabel *)[cell.contentView viewWithTag:100];
        tipsLabel.text = model.tips;
        
        if (model.status == XMVCommissionProcessing || model.status == XMVCommissionWaiting || model.status == XMVCommissionReviewFailed || model.status == XMVCommissionFailed) {
            tipsLabel.textColor = HEXCOLOR(@"#FF7428");
        } else if (model.status == XMVCommissionPayWaiting) {
            tipsLabel.textColor = HEXCOLOR(@"#E32A47");
        } else {
            tipsLabel.textColor = HEXCOLOR(@"#18D06A");
        }
    });
    
    return tipsCell;
}

- (CKDict *)setupCommissionTitleCell
{
    CKDict *commissionTitleCell = [CKDict dictWith:@{kCKItemKey: @"commissionTitleCell", kCKCellID: @"CommissionTitleCell"}];
    @weakify(self);
    commissionTitleCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 44;
    });
    
    commissionTitleCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:100];
        UIView *dottedLineView = (UIView *)[cell.contentView viewWithTag:101];
        
        titleLabel.text = @"代办订单";
        [self drawDashLine:dottedLineView lineLength:5 lineSpacing:3 lineColor:HEXCOLOR(@"#DEDFE0")];
    });
    
    return commissionTitleCell;
}

- (CKDict *)setupCommissionListCellWithDict:(NSDictionary *)dict
{
    CKDict *commissionListCell = [CKDict dictWith:@{kCKItemKey: @"ommissionListCell", kCKCellID: @"CommissionListCell"}];
    commissionListCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 24;
    });
    
    commissionListCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:100];
        UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:101];
        
        NSArray *titleArray = [dict allKeys];
        NSArray *contentArray = [dict allValues];
        NSString *titleString = titleArray.firstObject;
        NSString *contentString = contentArray.firstObject;
        
        titleLabel.text = titleString;
        contentLabel.text = contentString;
        
        if ([titleString isEqualToString:@"完成时间"] || [titleString isEqualToString:@"违章罚款"] || [titleString isEqualToString:@"手续费"] || [titleString isEqualToString:@"支付金额"]) {
            contentLabel.textColor = HEXCOLOR(@"#FF7428");
        } else {
            contentLabel.textColor = HEXCOLOR(@"#888888");
        }
    });
    
    return commissionListCell;
}

- (CKDict *)setupPayCellWithModel:(ViolationCommissionStateModel *)model
{
    CKDict *payCell = [CKDict dictWith:@{kCKItemKey: @"payCell", kCKCellID: @"PayCell"}];
    @weakify(self);
    payCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 63;
    });
    
    payCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UIButton *abandonButton = (UIButton *)[cell.contentView viewWithTag:100];
        UIButton *payButton = (UIButton *)[cell.contentView viewWithTag:101];
        
        [[[abandonButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            [self actionAbandon:abandonButton];
        }];
        
        [[[payButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            [self actionPay:payButton];
        }];
    });
    
    return payCell;
}

- (CKDict *)setupFailedCellWithStatus:(XMViolationCommissionStatus)status
{
    CKDict *failedCell = [CKDict dictWith:@{kCKItemKey: @"failedCell", kCKCellID: @"FailedCell"}];
    failedCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 48;
    });
    
    failedCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:100];
        
        if (status == XMVCommissionReviewFailed) {
            titleLabel.text = @"证件审核失败";
        } else {
            titleLabel.text = @"代办失败";
        }
    });
    
    return failedCell;
}

- (CKDict *)setupProofCellWithModel:(ViolationCommissionStateModel *)model
{
    CKDict *proofCell = [CKDict dictWith:@{kCKItemKey: @"proofCell", kCKCellID: @"ProofCell"}];
    proofCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 500;
    });
    
    proofCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1001];
        NSString *imageURL = @"http://img1.gamersky.com/image2016/07/20160731_lr_176_1/gamersky_05small_10_20167311169C2.jpg";
        self.proofImageURL = imageURL;
        [imageView setImageByUrl:imageURL withType:ImageURLTypeOrigin defImage:@"cm_shop" errorImage:@"cm_shop"];
        self.proofCell = cell;
        self.proofImage = imageView.image;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
        singleTap.numberOfTapsRequired = 1;
        [imageView setUserInteractionEnabled:YES];
        [imageView addGestureRecognizer:singleTap];
    });
    
    return proofCell;
}

- (CKDict *)setupBlankCell
{
    CKDict *blankCell = [CKDict dictWith:@{kCKItemKey: @"blankCell", kCKCellID: @"BlankCell"}];
    blankCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 12;
    });
    
    blankCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        
    });
    
    return blankCell;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CKList *cellList = self.dataSource[section];
    return cellList.count;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item[kCKCellID] forIndexPath:indexPath];
    CKCellPrepareBlock block = item[kCKCellPrepare];
    
    if (block) {
        block (item, cell, indexPath);
    }
    
    return cell;
}

#pragma mark - Utilities
// 返回虚线image的方法
- (void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame))];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    //  设置虚线宽度
    [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL,CGRectGetWidth(lineView.frame), 0);
    [shapeLayer setPath:path];
    CGPathRelease(path);
    //  把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
    lineView.layer.masksToBounds = YES;
}

- (void)tapDetected
{
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.sourceImagesContainerView = self.proofCell;
    browser.imageCount = 1;
    browser.currentImageIndex = 0;
    browser.delegate = self;
    browser.sourceImagesContainerViewContentMode = sourceImagesContainerViewContentFill;
    [browser show];
}

#pragma mark - SDPhotoBrowserDelegate
// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    NSString *strurl = [gMediaMgr urlWith:self.proofImageURL imageType:ImageURLTypeOrigin];
    UIImage *cachedImg = [gMediaMgr imageFromMemoryCacheForUrl:strurl];
    return cachedImg ? cachedImg : [UIImage imageNamed:@"cm_shop"];
}


// 返回高质量图片的url
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    return [NSURL URLWithString:[gMediaMgr urlWith:self.proofImageURL imageType:ImageURLTypeOrigin]];
}

@end
