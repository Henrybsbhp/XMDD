#import "TMCache.h"

NSString * const TMCachePrefix = @"com.tumblr.TMCache";
NSString * const TMCacheSharedName = @"TMCacheShared";

@interface TMCache ()
#if OS_OBJECT_USE_OBJC
@property (strong, nonatomic) dispatch_queue_t queue;
#else
@property (assign, nonatomic) dispatch_queue_t queue;
#endif
@end

@implementation TMCache

#pragma mark - Initialization -

#if !OS_OBJECT_USE_OBJC
- (void)dealloc
{
    dispatch_release(_queue);
    _queue = nil;
}
#endif

- (instancetype)initWithName:(NSString *)name
{
    if (!name)
        return nil;

    if (self = [super init]) {
        _name = [name copy];
        
        NSString *queueName = [[NSString alloc] initWithFormat:@"%@.%p", TMCachePrefix, self];
        _queue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_CONCURRENT);

        _diskCache = [[TMDiskCache alloc] initWithName:_name];
        _memoryCache = [[TMMemoryCache alloc] init];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"%@.%@.%p", TMCachePrefix, _name, self];
}

+ (instancetype)sharedCache
{
    static id cache;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        cache = [[self alloc] initWithName:TMCacheSharedName];
    });

    return cache;
}

#pragma mark - Public Asynchronous Methods -

- (void)objectForKey:(NSString *)key block:(TMCacheObjectBlock)block
{
    if (!key || !block)
        return;

    __weak TMCache *weakSelf = self;

    dispatch_async(_queue, ^{
        TMCache *strongSelf = weakSelf;
        if (!strongSelf)
            return;

        __weak TMCache *weakSelf = strongSelf;
        
        [strongSelf->_memoryCache objectForKey:key block:^(TMMemoryCache *cache, NSString *key, id object) {
            TMCache *strongSelf = weakSelf;
            if (!strongSelf)
                return;
            
            if (object) {
                [strongSelf->_diskCache fileURLForKey:key block:^(TMDiskCache *cache, NSString *key, id <NSCoding> object, NSURL *fileURL) {
                    // update the access time on disk
                }];

                __weak TMCache *weakSelf = strongSelf;
                
                dispatch_async(strongSelf->_queue, ^{
                    TMCache *strongSelf = weakSelf;
                    if (strongSelf)
                        block(strongSelf, key, object);
                });
            } else {
                __weak TMCache *weakSelf = strongSelf;

                [strongSelf->_diskCache objectForKey:key block:^(TMDiskCache *cache, NSString *key, id <NSCoding> object, NSURL *fileURL) {
                    TMCache *strongSelf = weakSelf;
                    if (!strongSelf)
                        return;
                    
                    [strongSelf->_memoryCache setObject:object forKey:key block:nil];
                    
                    __weak TMCache *weakSelf = strongSelf;
                    
                    dispatch_async(strongSelf->_queue, ^{
                        TMCache *strongSelf = weakSelf;
                        if (strongSelf)
                            block(strongSelf, key, object);
                    });
                }];
            }
        }];
    });
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key block:(TMCacheObjectBlock)block
{
    if (!key || !object)
        return;

    dispatch_group_t group = nil;
    TMMemoryCacheObjectBlock memBlock = nil;
    TMDiskCacheObjectBlock diskBlock = nil;
    
    if (block) {
        group = dispatch_group_create();
        dispatch_group_enter(group);
        dispatch_group_enter(group);
        
        memBlock = ^(TMMemoryCache *cache, NSString *key, id object) {
            dispatch_group_leave(group);
        };
        
        diskBlock = ^(TMDiskCache *cache, NSString *key, id <NSCoding> object, NSURL *fileURL) {
            dispatch_group_leave(group);
        };
    }
    
    [_memoryCache setObject:object forKey:key block:memBlock];
    [_diskCache setObject:object forKey:key block:diskBlock];
    
    if (group) {
        __weak TMCache *weakSelf = self;
        dispatch_group_notify(group, _queue, ^{
            TMCache *strongSelf = weakSelf;
            if (strongSelf)
                block(strongSelf, key, object);
        });
        
        #if !OS_OBJECT_USE_OBJC
        dispatch_release(group);
        #endif
    }
}

- (void)removeObjectForKey:(NSString *)key block:(TMCacheObjectBlock)block
{
    if (!key)
        return;
    
    dispatch_group_t group = nil;
    TMMemoryCacheObjectBlock memBlock = nil;
    TMDiskCacheObjectBlock diskBlock = nil;
    
    if (block) {
        group = dispatch_group_create();
        dispatch_group_enter(group);
        dispatch_group_enter(group);
        
        memBlock = ^(TMMemoryCache *cache, NSString *key, id object) {
            dispatch_group_leave(group);
        };
        
        diskBlock = ^(TMDiskCache *cache, NSString *key, id <NSCoding> object, NSURL *fileURL) {
            dispatch_group_leave(group);
        };
    }

    [_memoryCache removeObjectForKey:key block:memBlock];
    [_diskCache removeObjectForKey:key block:diskBlock];
    
    if (group) {
        __weak TMCache *weakSelf = self;
        dispatch_group_notify(group, _queue, ^{
            TMCache *strongSelf = weakSelf;
            if (strongSelf)
                block(strongSelf, key, nil);
        });
        
        #if !OS_OBJECT_USE_OBJC
        dispatch_release(group);
        #endif
    }
}

- (void)removeAllObjects:(TMCacheBlock)block
{
    dispatch_group_t group = nil;
    TMMemoryCacheBlock memBlock = nil;
    TMDiskCacheBlock diskBlock = nil;
    
    if (block) {
        group = dispatch_group_create();
        dispatch_group_enter(group);
        dispatch_group_enter(group);
        
        memBlock = ^(TMMemoryCache *cache) {
            dispatch_group_leave(group);
        };
        
        diskBlock = ^(TMDiskCache *cache) {
            dispatch_group_leave(group);
        };
    }
    
    [_memoryCache removeAllObjects:memBlock];
    [_diskCache removeAllObjects:diskBlock];
    
    if (group) {
        __weak TMCache *weakSelf = self;
        dispatch_group_notify(group, _queue, ^{
            TMCache *strongSelf = weakSelf;
            if (strongSelf)
                block(strongSelf);
        });
        
        #if !OS_OBJECT_USE_OBJC
        dispatch_release(group);
        #endif
    }
}

- (void)trimToDate:(NSDate *)date block:(TMCacheBlock)block
{
    if (!date)
        return;

    dispatch_group_t group = nil;
    TMMemoryCacheBlock memBlock = nil;
    TMDiskCacheBlock diskBlock = nil;
    
    if (block) {
        group = dispatch_group_create();
        dispatch_group_enter(group);
        dispatch_group_enter(group);
        
        memBlock = ^(TMMemoryCache *cache) {
            dispatch_group_leave(group);
        };
        
        diskBlock = ^(TMDiskCache *cache) {
            dispatch_group_leave(group);
        };
    }
    
    [_memoryCache trimToDate:date block:memBlock];
    [_diskCache trimToDate:date block:diskBlock];
    
    if (group) {
        __weak TMCache *weakSelf = self;
        dispatch_group_notify(group, _queue, ^{
            TMCache *strongSelf = weakSelf;
            if (strongSelf)
                block(strongSelf);
        });
        
        #if !OS_OBJECT_USE_OBJC
        dispatch_release(group);
        #endif
    }
}

#pragma mark - Public Synchronous Accessors -

- (NSUInteger)diskByteCount
{
    __block NSUInteger byteCount = 0;
    
    dispatch_sync([TMDiskCache sharedQueue], ^{
        byteCount = self.diskCache.byteCount;
    });
    
    return byteCount;
}

#pragma mark - Public Synchronous Methods -

- (id)objectForKey:(NSString *)key
{
    if (!key)
        return nil;
    
    __block id objectForKey = nil;

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [self objectForKey:key block:^(TMCache *cache, NSString *key, id object) {
        objectForKey = object;
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    #if !OS_OBJECT_USE_OBJC
    dispatch_release(semaphore);
    #endif

    return objectForKey;
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key
{
    if (!object || !key)
        return;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [self setObject:object forKey:key block:^(TMCache *cache, NSString *key, id object) {
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    #if !OS_OBJECT_USE_OBJC
    dispatch_release(semaphore);
    #endif
}

- (void)removeObjectForKey:(NSString *)key
{
    if (!key)
        return;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [self removeObjectForKey:key block:^(TMCache *cache, NSString *key, id object) {
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    #if !OS_OBJECT_USE_OBJC
    dispatch_release(semaphore);
    #endif
}

- (void)trimToDate:(NSDate *)date
{
    if (!date)
        return;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [self trimToDate:date block:^(TMCache *cache) {
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    #if !OS_OBJECT_USE_OBJC
    dispatch_release(semaphore);
    #endif
}

- (void)removeAllObjects
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [self removeAllObjects:^(TMCache *cache) {
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    #if !OS_OBJECT_USE_OBJC
    dispatch_release(semaphore);
    #endif
}

- (UIImage *)imageForKey:(NSString *)key
{
    NSObject *obj = [self.memoryCache objectForKey:key];
    if ([obj isKindOfClass:[UIImage class]])
    {
        return (UIImage *)obj;
    }
    else if ([obj isKindOfClass:[NSData class]])
    {
        NSData *data = (NSData *)obj;
        return [UIImage imageWithData:data];
    }
    obj = [self.diskCache imageForKey:key];
    if (obj)
    {
        [self.memoryCache setObject:obj forKey:key];
    }
    return (UIImage *)obj;
}

- (void)imageForKey:(NSString *)key block:(TMCacheObjectBlock)block
{
    if (!key || !block)
        return;
    
    __weak TMCache *weakSelf = self;
    
    dispatch_async(_queue, ^{
        TMCache *strongSelf = weakSelf;
        if (!strongSelf)
            return;
        
        __weak TMCache *weakSelf = strongSelf;
        
        [strongSelf->_memoryCache objectForKey:key block:^(TMMemoryCache *cache, NSString *key, id object) {
            TMCache *strongSelf = weakSelf;
            if (!strongSelf)
                return;
            
            if (object) {
                
                __weak TMCache *weakSelf = strongSelf;
                
                dispatch_async(strongSelf->_queue, ^{
                    TMCache *strongSelf = weakSelf;
                    if (strongSelf)
                        block(strongSelf, key, object);
                });
            } else {
                __weak TMCache *weakSelf = strongSelf;
                
                [strongSelf->_diskCache imageForKey:key block:^(TMDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) {
                    TMCache *strongSelf = weakSelf;
                    if (!strongSelf)
                        return;
                    
                    [strongSelf->_memoryCache setObject:object forKey:key block:nil];
                    
                    __weak TMCache *weakSelf = strongSelf;
                    
                    dispatch_async(strongSelf->_queue, ^{
                        TMCache *strongSelf = weakSelf;
                        if (strongSelf)
                            block(strongSelf, key, object);
                    });
                }];
            }
        }];
    });
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key
{
    [self.memoryCache setObject:image forKey:key];
    [self.diskCache setImage:image forKey:key];
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key block:(TMCacheObjectBlock)block
{
    if (!key || !image)
        return;
    
    dispatch_group_t group = nil;
    TMMemoryCacheObjectBlock memBlock = nil;
    TMDiskCacheObjectBlock diskBlock = nil;
    
    if (block) {
        group = dispatch_group_create();
        dispatch_group_enter(group);
        dispatch_group_enter(group);
        
        memBlock = ^(TMMemoryCache *cache, NSString *key, id object) {
            dispatch_group_leave(group);
        };
        
        diskBlock = ^(TMDiskCache *cache, NSString *key, id <NSCoding> object, NSURL *fileURL) {
            dispatch_group_leave(group);
        };
    }
    
    [_memoryCache setObject:image forKey:key block:memBlock];
    [_diskCache setImage:image forKey:key block:diskBlock];
    
    if (group) {
        __weak TMCache *weakSelf = self;
        dispatch_group_notify(group, _queue, ^{
            TMCache *strongSelf = weakSelf;
            if (strongSelf)
                block(strongSelf, key, image);
        });
        
#if !OS_OBJECT_USE_OBJC
        dispatch_release(group);
#endif
    }
}

- (void)setFileData:(NSData *)data forKey:(NSString *)key
{
    if (data)
    {
        [self.memoryCache setObject:data forKey:key];
        [self.diskCache setFileData:data forKey:key];
    }
}

- (void)setFileData:(NSData *)data forKey:(NSString *)key block:(TMCacheObjectBlock)block
{
    if (!key || !data)
        return;
    
    dispatch_group_t group = nil;
    TMMemoryCacheObjectBlock memBlock = nil;
    TMDiskCacheObjectBlock diskBlock = nil;
    
    if (block) {
        group = dispatch_group_create();
        dispatch_group_enter(group);
        dispatch_group_enter(group);
        
        memBlock = ^(TMMemoryCache *cache, NSString *key, id object) {
            dispatch_group_leave(group);
        };
        
        diskBlock = ^(TMDiskCache *cache, NSString *key, id <NSCoding> object, NSURL *fileURL) {
            dispatch_group_leave(group);
        };
    }
    
    [_memoryCache setObject:data forKey:key block:memBlock];
    [_diskCache setFileData:data forKey:key block:diskBlock];
    
    if (group) {
        __weak TMCache *weakSelf = self;
        dispatch_group_notify(group, _queue, ^{
            TMCache *strongSelf = weakSelf;
            if (strongSelf)
                block(strongSelf, key, data);
        });
        
#if !OS_OBJECT_USE_OBJC
        dispatch_release(group);
#endif
    }
}

- (NSData *)fileDataForKey:(NSString *)key
{
    NSObject *obj = [self.memoryCache objectForKey:key];
    if ([obj isKindOfClass:[NSData class]])
    {
        return (NSData *)obj;
    }
    else if ([obj isKindOfClass:[UIImage class]])
    {
        return UIImagePNGRepresentation((UIImage *)obj);
    }
    return [self.diskCache fileDataForKey:key];
}

- (void)fileDataForKey:(NSString *)key block:(TMCacheObjectBlock)block
{
    if (!key || !block)
        return;
    
    __weak TMCache *weakSelf = self;
    
    dispatch_async(_queue, ^{
        TMCache *strongSelf = weakSelf;
        if (!strongSelf)
            return;
        
        __weak TMCache *weakSelf = strongSelf;
        
        [strongSelf->_memoryCache objectForKey:key block:^(TMMemoryCache *cache, NSString *key, id object) {
            TMCache *strongSelf = weakSelf;
            if (!strongSelf)
                return;
            
            if (object) {
                
                __weak TMCache *weakSelf = strongSelf;
                
                dispatch_async(strongSelf->_queue, ^{
                    TMCache *strongSelf = weakSelf;
                    if (strongSelf)
                        block(strongSelf, key, object);
                });
            } else {
                __weak TMCache *weakSelf = strongSelf;
                
                [strongSelf->_diskCache fileDataForKey:key block:^(TMDiskCache *cache, NSString *key, id <NSCoding> object, NSURL *fileURL) {
                    TMCache *strongSelf = weakSelf;
                    if (!strongSelf)
                        return;
                    
                    [strongSelf->_memoryCache setObject:object forKey:key block:nil];
                    
                    __weak TMCache *weakSelf = strongSelf;
                    
                    dispatch_async(strongSelf->_queue, ^{
                        TMCache *strongSelf = weakSelf;
                        if (strongSelf)
                            block(strongSelf, key, object);
                    });
                }];
            }
        }];
    });
}

@end

#pragma HC SVNT DRACONES
