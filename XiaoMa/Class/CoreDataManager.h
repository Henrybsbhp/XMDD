//
//  CoreDataManager.h
//  JTNewReader
//
//  Created by jtang on 14-3-10.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)sharedManager;

- (NSData *)archivedData:(id)list;

- (id)unarchivedData:(NSData *)data;

- (BOOL)saveContext;

#pragma mark - Initialize
- (BOOL)resetPersistentStoreAtDirPath:(NSString *)dirPath;

#pragma mark - Fetch
- (NSArray *)fetchObjectsWithFetchRequest:(NSFetchRequest *)req;
- (id)fetchFirstObjectWithFetchRequest:(NSFetchRequest *)req;

#pragma mark - Insert
- (id)insertNewObjectForEntityForName:(NSString *)entityName;
- (id)insertOrReplaceObjectForEntityName:(NSString *)entityName filterPredicate:(NSPredicate *)predicate;
#pragma mark - Delete
- (void)deleteAllObjectsWithFetchRequest:(NSFetchRequest *)req;
- (void)deleteFirstObjectWithFetchRequest:(NSFetchRequest *)req;
- (void)deleteObject:(NSManagedObject *)object;
#pragma mark - Update
- (void)updateObject:(NSManagedObject *)object mergeChanges:(BOOL)flag;

@end
