//
//  MutualInsGroupDetailNoticeBoardVC.m
//  XMDD
//
//  Created by RockyYe on 2016/10/21.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGroupDetailNoticeBoardVC.h"
#import "MutualInsGroupNoticeItemCell.h"
#import "GetCooperationClaimsListV2Op.h"
#import "NSString+RectSize.h"
@interface MutualInsGroupDetailNoticeBoardVC ()<UITableViewDelegate>

@end

@implementation MutualInsGroupDetailNoticeBoardVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTableView];
    [self subscribeReloadSignal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupTableView
{
    [self.tableView registerClass:[MutualInsGroupNoticeItemCell class] forCellReuseIdentifier:@"NoticeItemCell"];
    [self.tableView registerClass:[MutualInsGroupNoticeItemCell class] forCellReuseIdentifier:@"BlankCell"];
}

#pragma mark - Subscribe

- (void)subscribeReloadSignal {
    @weakify(self);
    [[RACObserve(self.viewModel, reloadNoticeInfoSignal) distinctUntilChanged] subscribeNext:^(RACSignal *signal) {
        
        @strongify(self);
        [[signal initially:^{
            
            @strongify(self);
            [self.tableView setHidden:YES animated:NO];
            CGPoint pos = CGPointMake(ScreenWidth/2, ScreenHeight/2 - 64);
            [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:pos];
        }] subscribeNext:^(GetCooperationClaimsListV2Op *op) {
            
            @strongify(self);
            [self.view stopActivityAnimation];
            if (self.viewModel.noticeInfo.rsp_claimlist.count == 0)
            {
                [self.view showImageEmptyViewWithImageName:@"def_noGroupMembers" text:@"暂无任何补偿公示" tapBlock:^{
                    
                    @strongify(self);
                    [self.view hideDefaultEmptyView];
                    [self.viewModel fetchNoticeInfoForce:YES];
                }];
            }
            else
            {
                [self.tableView setHidden:NO animated:YES];
                [self itemsForNoticeList:op.rsp_claimlist];
            }
        } error:^(NSError *error) {
            
            @strongify(self);
            [self.view stopActivityAnimation];
            [self.view showImageEmptyViewWithImageName:kImageFailConnect text:error.domain tapBlock:^{
                @strongify(self);
                [self.view hideDefaultEmptyView];
                [self.viewModel fetchMembersInfoForce:YES];
            }];
            
        }];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

#pragma mark - Datasource

- (void)itemsForNoticeList:(NSArray *)list {
    
    self.datasource = [CKList list];
    CKList *data = [CKList list];
    
    for (NSInteger i = 0; i < list.count; i++)
    {
        NSArray *notices = [list safetyObjectAtIndex:i];
        NSMutableArray *mArr = [[NSMutableArray alloc]init];
        [mArr addObject:[self blankCellWithSeparator:YES height:10]];
        for (NSDictionary *notice in notices){
            [mArr addObject:[self itemForNotice:notice]];
        }
        if (i != list.count - 1)
        {
            [mArr addObject:[self blankCellWithSeparator:NO height:18]];
        }
        else
        {
            [mArr addObject:[self blankCellWithSeparator:YES height:10]];
        }
        
        [data addObjectsFromArray:mArr];
    }

    [self.datasource addObject:data forKey:nil];
    [self.tableView reloadData];
}

- (CKDict *)blankCellWithSeparator:(BOOL)separator height:(CGFloat)height
{
    CKDict *item = [CKDict dictWith:@{kCKCellID: @"BlankCell"}];
    
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return height;
    });
    
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, MutualInsGroupNoticeItemCell *cell, NSIndexPath *indexPath) {
        
        if (![cell viewWithTag:100])
        {
            UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Horizontaline"]];
            [cell.contentView addSubview:imgView];
            imgView.tag = 100;
            
            [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.height.mas_equalTo(1);
                make.left.mas_equalTo(15);
                make.right.mas_equalTo(0);
                make.centerY.mas_equalTo(5);
            }];
        }
        UIImageView *imgView = [cell viewWithTag:100];
        imgView.hidden = separator;
    });
    
    return item;
}

- (CKDict *)itemForNotice:(NSDictionary *)notice
{
    
    CKDict *item = [CKDict dictWith:@{kCKCellID: @"NoticeItemCell"}];
    
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        CGFloat height = [(NSString *)notice.allValues.firstObject labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 100 font:[UIFont systemFontOfSize:13]].height;
        height = height > 25 ? ceil(height + 10) : 25;
        return height;
    });
    
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, MutualInsGroupNoticeItemCell *cell, NSIndexPath *indexPath) {
        
        cell.titleLabel.text = notice.allKeys.firstObject;
        if ([notice.allValues.firstObject rangeOfString:@"</font>"].length == 0)
        {
            cell.contentLabel.text = notice.allValues.firstObject;
        }
        else
        {
            cell.contentLabel.attributedText = [[NSAttributedString alloc]
                                                initWithData:[notice.allValues.firstObject dataUsingEncoding:NSUTF8StringEncoding]
                                                options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                          NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                documentAttributes:nil error:nil];
        }
        
        
    });
    
    return item;
}

@end
