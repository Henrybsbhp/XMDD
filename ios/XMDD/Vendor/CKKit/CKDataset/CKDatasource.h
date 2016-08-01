//
//  CKDatasource.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/19.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKList.h"

///info的默认Key
#define kCKCellID           @"__cellid"
#define kCKCellGetHeight    @"__getcellheight"
#define kCKCellPrepare      @"__preparecell"
#define kCKCellSelected     @"__selectcell"
#define kCKCellWillDisplay   @"__willdisplaycell"

#define CKNULL     [NSNull null]

#if defined __cplusplus
extern "C"
{
#endif
    typedef void (^CKCellSelectedBlock)(CKDict *data, NSIndexPath *indexPath);
    typedef CGFloat (^CKCellGetHeightBlock)(CKDict *data, NSIndexPath *indexPath);
    typedef void(^CKCellPrepareBlock)(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath);
    typedef void(^CKCellWillDisplayBlock)(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath);

    CKCellSelectedBlock CKCellSelected(CKCellSelectedBlock block);
    CKCellGetHeightBlock CKCellGetHeight(CKCellGetHeightBlock block);
    CKCellPrepareBlock CKCellPrepare(CKCellPrepareBlock block);
    CKCellWillDisplayBlock CKCellWillDisplay(CKCellWillDisplayBlock block);
    
    CKList *CKGenList(id firstObject, ...) NS_REQUIRES_NIL_TERMINATION;
    CKList *CKSplicList(id firstObject, ...) NS_REQUIRES_NIL_TERMINATION;
    CKList *CKJoinArray(NSArray *array);

#define $(...) CKGenList(__VA_ARGS__,nil)
#define CKJoin(array) CKJoinArray(array)

#if defined __cplusplus
};
#endif




