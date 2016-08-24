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
#import "RTLabel.h"
#import "ViolationPayConfirmVC.h"

@interface ViolationCommissionStateVC () <UITableViewDelegate, UITableViewDataSource, SDPhotoBrowserDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) CKList *dataSource;

@property (nonatomic, strong) UITableViewCell *proofCell;

@property (nonatomic, strong) UIImage *proofImage;

@property (nonatomic, copy) NSString *proofImageURL;

@end

@implementation ViolationCommissionStateVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    [self cancelListenNotificationByName:kNotifyViolationPaySuccess];
    DebugLog(@"ViolationComissionStateVC is deallocated");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /// 当获取到凭证图片后，立即刷新页面适应凭证图片 Cell 的高度
    @weakify(self);
    [[RACObserve(self, proofImage) distinctUntilChanged] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    [self observeViolationPaySuccessEvent];
    
    [self fetchStateData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notification observe
/// 监听是否支付成功，如成功则刷新页面
- (void)observeViolationPaySuccessEvent
{
    @weakify(self)
    [self listenNotificationByName:kNotifyViolationPaySuccess withNotifyBlock:^(NSNotification *note, id weakSelf) {
        @strongify(self)
        [self fetchStateData];
    }];
}

#pragma mark - Actions
/// 支付按钮点击事件
- (void)actionPay
{
    ViolationPayConfirmVC *vc = [UIStoryboard vcWithId:@"ViolationPayConfirmVC" inStoryboard:@"Violation"];
    vc.recordID = self.recordID;
    [self.navigationController pushViewController:vc animated:YES];
}

/// 放弃按钮点击事件
- (void)actionAbandon:(UIButton *)sender
{
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确认放弃" color:kDefTintColor clickBlock:^(id alertVC) {
        CancelViolationCommissionOp *op = [CancelViolationCommissionOp operation];
        op.recordID = self.recordID;
        @weakify(self);
        [[[op rac_postRequest] initially:^{
            [gToast showingWithText:nil];
        }] subscribeNext:^(id x) {
            @strongify(self);
            [gToast showSuccess:@"取消代办成功"];
            [self postCustomNotificationName:kNotifyCommissionAbandoned object:nil];
            [self fetchStateData];
        } error:^(NSError *error) {
            [gToast showMistake:error.domain];
        }];
        
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"请确认是否放弃代办？" ActionItems:@[cancel, confirm]];
    [alert show];
}

/// 联系客服按钮点击事件
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
/// 获取数据
- (void)fetchStateData
{
    GetViolationCommissionStateOp *op = [GetViolationCommissionStateOp operation];
    op.recordID = self.recordID;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        @strongify(self);
        CGFloat reducingY = self.view.frame.size.height * 0.1056;
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:CGPointMake(self.view.center.x, self.view.center.y - reducingY)];
        self.tableView.hidden = YES;
        
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

/// 通过 model 设置 dataSource 的方法
- (void)setDataSourceWithFetchedData:(ViolationCommissionStateModel *)model
{
    self.dataSource = [CKList list];
    
    // 通过状态设置 dataSource 的样式
    if (model.status == XMVCommissionWaiting) {
        // 等待受理
        
        [self.dataSource addObject:$([self setupProgressViewCellWithIndex:1], [self setupCarDescCellWithModel:model], [self setupTipsCellWithModel:model]) forKey:nil];
        
    } else if (model.status == XMVCommissionPayWaiting) {
        // 待支付
        
        NSMutableArray *cellArray = [NSMutableArray array];
        for (NSDictionary *dict in model.orderInfo) {
            CKDict *commissionListCell = [self setupCommissionListCellWithDict:dict];
            [cellArray addObject:commissionListCell];
        }
        [self.dataSource addObject:$([self setupProgressViewCellWithIndex:2], [self setupCarDescCellWithModel:model], [self setupCommissionTitleCell], [self setupBlankCell], CKJoin(cellArray), [self setupBlankCell], [self setupTipsCellWithModel:model], [self setupPayCellWithModel:model]) forKey:nil];
        
    } else if (model.status == XMVCommissionProcessing) {
        // 代办中
        
        NSMutableArray *cellArray = [NSMutableArray array];
        for (NSDictionary *dict in model.orderInfo) {
            CKDict *commissionListCell = [self setupCommissionListCellWithDict:dict];
            [cellArray addObject:commissionListCell];
        }
        [self.dataSource addObject:$([self setupProgressViewCellWithIndex:3], [self setupCarDescCellWithModel:model], [self setupCommissionTitleCell], [self setupBlankCell], CKJoin(cellArray), [self setupBlankCell], [self setupTipsCellWithModel:model]) forKey:nil];
        
    } else if (model.status == XMVCommissionComplete) {
        // 代办完成
        
        NSMutableArray *cellArray = [NSMutableArray array];
        for (NSDictionary *dict in model.orderInfo) {
            CKDict *commissionListCell = [self setupCommissionListCellWithDict:dict];
            [cellArray addObject:commissionListCell];
        }
        
        // 如有凭证图片 URL 则显示
        if (model.finishPicURL.length > 0) {
            [self.dataSource addObject:$([self setupProgressViewCellWithIndex:4], [self setupCarDescCellWithModel:model], [self setupCommissionTitleCell], [self setupBlankCell], CKJoin(cellArray), [self setupBlankCell], [self setupTipsCellWithModel:model], [self setupProofCellWithModel:model]) forKey:nil];
        } else {
            [self.dataSource addObject:$([self setupProgressViewCellWithIndex:4], [self setupCarDescCellWithModel:model], [self setupCommissionTitleCell], [self setupBlankCell], CKJoin(cellArray), [self setupBlankCell], [self setupTipsCellWithModel:model]) forKey:nil];
        }
        
    } else if (model.status == XMVCommissionReviewFailed) {
        // 证件审核失败
        
        [self.dataSource addObject:$([self setupFailedCellWithStatus:XMVCommissionReviewFailed], [self setupCarDescCellWithModel:model], [self setupTipsCellWithModel:model]) forKey:nil];
        
    } else {
        // 代办失败
        
        [self.dataSource addObject:$([self setupFailedCellWithStatus:model.status], [self setupCarDescCellWithModel:model], [self setupTipsCellWithModel:model]) forKey:nil];
        
    }
    
    [self.tableView reloadData];
}

#pragma mark - The settings of Cells
/// 顶部代办状态进度条
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

/// 车牌号，位置，行为 Cell
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
        
        carNumLabel.text = model.licenceNumber;
        locationLabel.text = model.area;
        descLabel.text = model.act;
    });
    
    return carDescCell;
}

/// 提示 Tips Cell
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

/// 代办订单的标题
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

/// 代办订单的信息列表
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
        
        NSMutableAttributedString *res = [[NSMutableAttributedString alloc] initWithData:[contentArray.firstObject dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                   NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                              documentAttributes:nil error:nil];
        [res beginEditing];
        [res enumerateAttribute:NSFontAttributeName
                        inRange:NSMakeRange(0, res.length)
                        options:0
                     usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                         if (value) {
                             UIFont *newFont = [UIFont systemFontOfSize:14];
                             [res addAttribute:NSFontAttributeName value:newFont range:range];
                         }
                     }];
        [res endEditing];
        
        titleLabel.text = titleArray.firstObject;
        contentLabel.attributedText = res;
        contentLabel.textAlignment = NSTextAlignmentRight;
    });
    
    return commissionListCell;
}

/// 前往支付 / 放弃的 Cell
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
            @strongify(self);
            [self actionAbandon:abandonButton];
        }];
        
        [[[payButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            @strongify(self);
            [self actionPay];
        }];
    });
    
    return payCell;
}

/// 失败状态下的顶部 Cell
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

/// 代办凭证 Cell
- (CKDict *)setupProofCellWithModel:(ViolationCommissionStateModel *)model
{
    @weakify(self);
    CKDict *proofCell = [CKDict dictWith:@{kCKItemKey: @"proofCell", kCKCellID: @"ProofCell"}];
    proofCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        if (self.proofImage) {
            CGFloat multiple = self.proofImage.size.width / gAppMgr.deviceInfo.screenSize.width;
            return self.proofImage.size.height / multiple + 40;
        }
        return gAppMgr.deviceInfo.screenSize.width / 2.2;
    });
    
    proofCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1001];
        self.proofImageURL = model.finishPicURL;
        NSURL *URL = [NSURL URLWithString:model.finishPicURL];
        UIImage *placeholderImg = [UIImage imageNamed:@"violation_imgLoading"];
        [imageView sd_setImageWithURL:URL placeholderImage:placeholderImg completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            @strongify(self);
            if (error) {
                imageView.image = [UIImage imageNamed:@"violation_imgError"];
                self.proofImage = [UIImage imageNamed:@"violation_imgError"];
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetectedWhileErrorOccrured:)];
                singleTap.numberOfTapsRequired = 1;
                [imageView setUserInteractionEnabled:YES];
                [imageView addGestureRecognizer:singleTap];
            } else {
                self.proofImage = image;
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
                singleTap.numberOfTapsRequired = 1;
                [imageView setUserInteractionEnabled:YES];
                [imageView addGestureRecognizer:singleTap];
            }
        }];
        self.proofCell = cell;
    });
    
    return proofCell;
}

/// 空白 Cell（作为填充用）
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
// 画虚线的方法
- (void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame))];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    // 通过 lineColor 设置虚线的颜色
    [shapeLayer setStrokeColor:lineColor.CGColor];
    // 通过 lineView 设置虚线宽度
    [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];
    // 设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
    // 设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, CGRectGetWidth(lineView.frame), 0);
    [shapeLayer setPath:path];
    CGPathRelease(path);
    // 把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
    lineView.layer.masksToBounds = YES;
}

/// 点击查看图片的方法
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

/// 当获取图片失败则点击重新获取图片
- (void)tapDetectedWhileErrorOccrured:(UIGestureRecognizer *)gesture
{
    [self.tableView reloadData];
}

#pragma mark - SDPhotoBrowserDelegate
// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    UIImage *cachedImg = [gMediaMgr imageFromMemoryCacheForUrl:self.proofImageURL];
    return cachedImg ? cachedImg : [UIImage imageNamed:@"violation_imgLoading"];
}


// 返回高质量图片的 URL
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    return [NSURL URLWithString:self.proofImageURL];
}

@end
