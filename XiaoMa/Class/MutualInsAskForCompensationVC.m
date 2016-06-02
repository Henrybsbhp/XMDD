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
#import "NSString+RectSize.h"
#import "UIImage+Utilities.h"

#define StamperImageWidthHeight 120

@interface MutualInsAskForCompensationVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) CKList *dataSource;
@property (nonatomic, copy) NSArray *fetchedDataSource;

@property (nonatomic, nonnull,strong)UIImage * stamperImage;

@end

@implementation MutualInsAskForCompensationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (IOSVersionGreaterThanOrEqualTo(@"8.0")) {
        self.tableView.estimatedRowHeight = 136;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    [self fetchAllData];
}

- (void)fetchAllData
{
    AskToCompensationOp *op = [[AskToCompensationOp alloc] init];
    
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"请求数据中，请稍后"];
    }] subscribeNext:^(AskToCompensationOp *rop) {
        @strongify(self);
        [gToast dismiss];
        self.fetchedDataSource = rop.claimList;
        [self setDataSource];
    } error:^(NSError *error) {
        [gToast showMistake:error.domain];
    }];
}

- (NSInteger)indexOfProgressViewFromFetchedStatus:(int)status fastClaimNo:(int)fastClaimNo
{
    if (status <= 0 || status == 4 || status == 2 || status == 5) {
        return 1;
    } else if (status == 1 || status == 10 || status == 20 || (fastClaimNo == 0 && status == 3) || (fastClaimNo == 1 && status == 2)) {
        return 2;
    } else {
        return 3;
    }
    
    return 1;
}

- (void)setDataSource
{
    self.dataSource = [CKList list];
    NSMutableArray *dataArray = [NSMutableArray new];
    for (NSDictionary *dict in self.fetchedDataSource) {
        
        int isFastClaimInt = [dict[@"isfastclaim"] intValue];
        int status = [dict[@"status"] intValue];
        NSArray *detailInfoArray = dict[@"detailinfo"];
        
        CKDict *progressCell = [CKDict dictWith:@{kCKItemKey: @"progressCell", kCKCellID: @"ProgressCell"}];
        progressCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
            return 48;
        });
        progressCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
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
        
        
        CKDict *statusCell = [CKDict dictWith:@{kCKItemKey: @"statusCell", kCKCellID: @"StatusCell"}];
        statusCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
            return 34;
        });
        statusCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
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
            if (status == -1 || status == 4 || status == 1) {
                imageName = @"common_statusTagRed_imageView";
            } else if (status == 0 || status == 2 || status == 10 || status == 20) {
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
        
        
        CKDict *detailCell = [CKDict dictWith:@{kCKItemKey: @"detailCell", kCKCellID: @"DetailCell"}];
        detailCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
            
            NSDictionary *dict = detailInfoArray[indexPath.row - 2];
            NSString * content = dict[[[dict allKeys] safetyObjectAtIndex:0]];
            NSString * title = [[dict allKeys] safetyObjectAtIndex:0];
            
            CGFloat height = [self heightOfDetailCell:content title:title];
    
            return ceil(height);
        });
        detailCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
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
            NSString * content = dict[[[dict allKeys] safetyObjectAtIndex:0]];
            NSString * title = [[dict allKeys] safetyObjectAtIndex:0];
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
        
        
        CKDict *tipsCell = [CKDict dictWith:@{kCKItemKey: @"tipsCell", kCKCellID: @"TipsCell"}];
        tipsCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
            if (IOSVersionGreaterThanOrEqualTo(@"8.0")) {
                
                return UITableViewAutomaticDimension;
                
            }
            
            UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
            [cell layoutIfNeeded];
            [cell setNeedsUpdateConstraints];
            [cell updateConstraintsIfNeeded];
            CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
            return ceil(size.height + 1);
        });
        tipsCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
            UILabel *tipsLabel = (UILabel *)[cell.contentView viewWithTag:100];
            CKLine *leftLine = (CKLine *)[cell.contentView viewWithTag:101];
            CKLine *rightLine = (CKLine *)[cell.contentView viewWithTag:102];
            
            leftLine.lineColor = kLightLineColor;
            leftLine.linePixelWidth = 1;
            leftLine.lineAlignment = CKLineAlignmentVerticalLeft;
            rightLine.lineColor = kLightLineColor;
            rightLine.linePixelWidth = 1;
            rightLine.lineAlignment = CKLineAlignmentVerticalRight;
            
            if (status == -1 || status == 4 || status == 1) {
                tipsLabel.textColor = [UIColor redColor];
            } else if (status == 0 || status == 2 || status == 10 || status == 20) {
                tipsLabel.textColor = HEXCOLOR(@"#E87131");
            } else {
                tipsLabel.textColor = HEXCOLOR(@"#18D06A");
            }
            
            tipsLabel.text = dict[@"detailstatusdes"];
        });
        
        
        CKDict *takePhotoCell = [CKDict dictWith:@{kCKItemKey: @"takePhotoCell", kCKCellID: @"TakePhotoCell"}];
        takePhotoCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
            return 44;
        });
        takePhotoCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
            UIButton *takePhotoButton = (UIButton *)[cell.contentView viewWithTag:100];
            CKLine *leftLine = (CKLine *)[cell.contentView viewWithTag:101];
            CKLine *rightLine = (CKLine *)[cell.contentView viewWithTag:102];
            
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
        });
        
        CKDict *compensateOrDeclineCell = [CKDict dictWith:@{kCKItemKey: @"compensateOrDeclineCell", kCKCellID: @"CompensateOrDeclineCell"}];
        compensateOrDeclineCell[kCKCellPrepare] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
            return 44;
        });
        compensateOrDeclineCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
            UIView *backgroundView = (UIView *)[cell.contentView viewWithTag:100];
            UIView *fillingView = (UIView *)[cell.contentView viewWithTag:105];
            UIButton *accpectCompensationButton = (UIButton *)[cell.contentView viewWithTag:101];
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
        });
        
        CKDict *compensationPriceBottomCell = [CKDict dictWith:@{kCKItemKey: @"compensationPriceBottomCell", kCKCellID: @"CompensationPriceBottomCell"}];
        compensationPriceBottomCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
            return 40;
        });
        compensationPriceBottomCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
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
            
            tipsLabel.text = @"补偿金额：8888.88元";
        });
        
        if ([dict[@"status"] integerValue] == -1) {
            CKList *waitingForPhoto = $(progressCell, statusCell);
            NSMutableArray *detailCellArray = [NSMutableArray new];
            int a;
            for (a = 0; a < detailInfoArray.count; a++) {
                [detailCellArray addObject:detailCell];
            }
            [waitingForPhoto addObjectsFromArray:detailCellArray];
            NSArray *remainingCell = @[tipsCell, takePhotoCell];
            [waitingForPhoto addObjectsFromArray:remainingCell];
            [dataArray addObject:waitingForPhoto];
        }
        
        if ([dict[@"status"] integerValue] == 0) {
            CKList *photoTook = $(progressCell, statusCell);
            NSMutableArray *detailCellArray = [NSMutableArray new];
            int a;
            for (a = 0; a < detailInfoArray.count; a++) {
                [detailCellArray addObject:detailCell];
            }
            [photoTook addObjectsFromArray:detailCellArray];
            NSArray *remainingCell = @[tipsCell];
            [photoTook addObjectsFromArray:remainingCell];
            [dataArray addObject:photoTook];
        }
        
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
        
        if ([dict[@"status"] integerValue] == 2) {
            CKList *compensating = $(progressCell, statusCell);
            NSMutableArray *detailCellArray = [NSMutableArray new];
            int a;
            for (a = 0; a < detailInfoArray.count; a++) {
                [detailCellArray addObject:detailCell];
            }
            [compensating addObjectsFromArray:detailCellArray];
            NSArray *remainingCell = @[tipsCell];
            [compensating addObjectsFromArray:remainingCell];
            [dataArray addObject:compensating];
        }
        
        if ([dict[@"status"] integerValue] == 3) {
            CKList *compensationEnded = $(progressCell, statusCell);
            NSMutableArray *detailCellArray = [NSMutableArray new];
            int a;
            for (a = 0; a < detailInfoArray.count; a++) {
                [detailCellArray addObject:detailCell];
            }
            [compensationEnded addObjectsFromArray:detailCellArray];
            NSArray *remainingCell = @[tipsCell];
            [compensationEnded addObjectsFromArray:remainingCell];
            [dataArray addObject:compensationEnded];
        }
        
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
        
        if ([dict[@"status"] integerValue] == 20) {
            CKList *systemDeclined = $(progressCell, statusCell);
            NSMutableArray *detailCellArray = [NSMutableArray new];
            int a;
            for (a = 0; a < detailInfoArray.count; a++) {
                [detailCellArray addObject:detailCell];
            }
            [systemDeclined addObjectsFromArray:detailCellArray];
            NSArray *remainingCell = @[tipsCell];
            [systemDeclined addObjectsFromArray:remainingCell];
            [dataArray addObject:systemDeclined];
        }
    }
    
    self.dataSource = [CKList listWithArray:dataArray];
    
    //    self.dataSource = $($(progressCell, statusCell, detailCell, detailCell, detailCell, tipsCell, compensationPriceBottomCell));
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource[section] count];
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

#pragma mark - Utilitly
- (CGFloat)heightOfDetailCell:(NSString *)content title:(NSString *)title
{
    CGSize titleSize = [title labelSizeWithWidth:9999 font:[UIFont systemFontOfSize:14]];
    
    CGSize size = [content labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 6*2 - 10 - titleSize.width - 10 font:[UIFont systemFontOfSize:14]];
    CGFloat height = size.height + 12 + 2;
    height = MAX(height, 35);
    return height;
}

#pragma mark - Lazy
- (UIImage *)stamperImage
{
    if (!_stamperImage)
    {
        _stamperImage = [[UIImage imageNamed:@"mutualIns_stamper_imageView"] scaleToSize:CGSizeMake(StamperImageWidthHeight,StamperImageWidthHeight)];
    }
    return _stamperImage;
}
@end
