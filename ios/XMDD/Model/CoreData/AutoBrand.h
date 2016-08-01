//
//  AutoBrand.h
//  
//
//  Created by jiangjunchen on 15/5/20.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AutoBrand : NSManagedObject

@property (nonatomic, retain) NSNumber * brandid;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * logo;
@property (nonatomic, retain) NSNumber * timetag;

@end
