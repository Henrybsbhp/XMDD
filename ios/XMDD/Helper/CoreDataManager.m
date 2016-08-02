//
//  CoreDataManager.m
//  JTNewReader
//
//  Created by jtang on 14-3-10.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "CoreDataManager.h"
#import <FoundationExtension.h>

#ifndef kDBName
#define kDBName @"xmdd2.sqlite"
#endif

@interface CoreDataManager ()
@property (nonatomic, strong) NSString *mDirPath;
@end

@implementation CoreDataManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype)sharedManager
{
    static CoreDataManager *g_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        g_manager = [[CoreDataManager alloc] init];
    });
    return g_manager;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}


- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"xmdd" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;

}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSString *storePath = [self.mDirPath stringByAppendingPathComponent:kDBName];
    if (storePath.length == 0)
    {
        return nil;
    }
    NSURL *storeURL = [NSURL smartURLWithPath:storePath];
//    NSURL *appDocDir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
//                                                               inDomains:NSUserDomainMask] lastObject];
//    NSURL *storeURL = [appDocDir URLByAppendingPathComponent:@"JTNewReader.sqlite"];

    NSError *error;
    NSManagedObjectModel *const model = [self managedObjectModel];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];

    // Allow inferred migration from the original version of the application.
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES,
            NSInferMappingModelAutomaticallyOption : @YES};

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error]) {
        DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}


- (NSData *)archivedData:(id)list
{
    return [NSKeyedArchiver archivedDataWithRootObject:list];
}

- (id)unarchivedData:(NSData *)data
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (BOOL)saveContext
{
    NSLog(@"SavingContext...");
//    DebugLog(@"SavingContext...");
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        [managedObjectContext save:&error];
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
            return NO;
        }
    }
    return YES;
}

#pragma mark - Initialize
- (BOOL)resetPersistentStoreAtDirPath:(NSString *)dirPath
{
    _managedObjectContext = nil;
    _managedObjectModel = nil;
    _persistentStoreCoordinator = nil;
    self.mDirPath = dirPath;
    return (BOOL)self.managedObjectContext;
}

#pragma mark - Fetch
- (NSArray *)fetchObjectsWithFetchRequest:(NSFetchRequest *)req
{
    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:req error:&error];

    if (error)
    {
        DebugLog(@"CoreData execute error:%@", error);
    }
    return results;
}

- (id)fetchFirstObjectWithFetchRequest:(NSFetchRequest *)req
{
    return [[self fetchObjectsWithFetchRequest:req] firstObject];
}

#pragma mark - Insert
- (id)insertNewObjectForEntityForName:(NSString *)entityName
{
    return [NSEntityDescription insertNewObjectForEntityForName:entityName
                                         inManagedObjectContext:self.managedObjectContext];
}

- (id)insertOrReplaceObjectForEntityName:(NSString *)entityName filterPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:entityName];
    req.predicate = predicate;
    NSManagedObject *obj = [self fetchFirstObjectWithFetchRequest:req];
    if (!obj)
    {
        obj = [self insertNewObjectForEntityForName:entityName];
    }
    return obj;
}
#pragma mark - Delete
- (void)deleteAllObjectsWithFetchRequest:(NSFetchRequest *)req
{
    NSArray *objs = [self fetchObjectsWithFetchRequest:req];
    for (NSManagedObject *obj in objs)
    {
        [self.managedObjectContext deleteObject:obj];
    }
}
- (void)deleteFirstObjectWithFetchRequest:(NSFetchRequest *)req
{
    id object = [self fetchFirstObjectWithFetchRequest:req];
    if (object) {
        [self.managedObjectContext deleteObject:object];
    }
}

- (void)deleteObject:(NSManagedObject *)object
{
    [self.managedObjectContext deleteObject:object];
}
#pragma mark - Update
- (void)updateObject:(NSManagedObject *)object mergeChanges:(BOOL)flag
{
    [self.managedObjectContext refreshObject:object mergeChanges:flag];
}
@end


