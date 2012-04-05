//
//  ErrorLogStoreCoordinator.m
//

#import "EventLogStoreCoordinator.h"

static EventLogStoreCoordinator* _sharedSingleton = nil;

@interface EventLogStoreCoordinator ()
- (NSURL *)applicationDocumentsDirectory;
- (void)addContextDidSave:(NSNotification*)saveNotification;

@end

@implementation EventLogStoreCoordinator

#pragma -
#pragma mark Static Methods

+ (BOOL)saveContext
{
    return [[EventLogStoreCoordinator globalObject] saveContext];
}

+ (NSManagedObject *) createObjectWithName:(NSString *)name
{
    return [[EventLogStoreCoordinator globalObject] createObjectWithName:name];
}

#pragma -
#pragma mark Instance Methods

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (BOOL)saveContext 
{
    return [self saveContextWithAutoContextRemoval:YES];
}

- (BOOL)saveContextWithAutoContextRemoval:(BOOL)autoRemove 
{    
    NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        
        NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
        [dnc addObserver:self selector:@selector(addContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:managedObjectContext];
        
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) 
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            [dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:managedObjectContext];
            return NO;
        } 
        [dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:managedObjectContext];
        
        if (autoRemove)
        {
            [self cleanupForThread:[NSThread currentThread]];
        }
    }
    return YES;
}

- (NSManagedObject *) createObjectWithName:(NSString *)name
{
    NSManagedObjectContext *context = self.managedObjectContext;
    return [NSEntityDescription insertNewObjectForEntityForName:name
										 inManagedObjectContext:context];
}

/**
 *  This method is triggered whenever an object context is saved.  It is used to merge the saved changes into 
 *  any other open object context so as to keep them all up to date.
 */
- (void)addContextDidSave:(NSNotification*)saveNotification {
    @synchronized (self)
    {
        for (NSManagedObjectContext *context in [managedObjectContexts_ allValues])
        {
            if (context != saveNotification.object)
            {
                [context mergeChangesFromContextDidSaveNotification:saveNotification];
            }
        }
    }
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (!managedObjectContexts_)
    {
        managedObjectContexts_ = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    NSString *threadKey = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
    NSManagedObjectContext *managedObjectContext = [managedObjectContexts_ objectForKey:threadKey];
    
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
        [managedObjectContexts_ setObject:managedObjectContext forKey:threadKey];
    }
    return [managedObjectContext autorelease];
}

- (BOOL)cleanupForThread:(NSThread *)thread
{    
    // Never remove the main thread's context.
    if ([thread isMainThread]) return NO;

    NSString *threadKey = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
    NSManagedObjectContext *context = [managedObjectContexts_ objectForKey:threadKey];
    if (context)
    {
        [managedObjectContexts_ removeObjectForKey:thread];
    }
    return YES;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"EventLog" ofType:@"momd"];
    if (!modelPath)
    {
        modelPath = [[NSBundle mainBundle] pathForResource:@"EventLog" ofType:@"mom"];
    }
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    @synchronized (self)
    {
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"EventLog.sqlite"];
        
        NSError *error = nil;
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES],
                                 NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES],
                                 NSInferMappingModelAutomaticallyOption, nil];
        persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }    
    }
    return persistentStoreCoordinator_;
}


#pragma -
#pragma mark Singleton Methods
+ (EventLogStoreCoordinator *) globalObject
{
    @synchronized ([EventLogStoreCoordinator class])
    {
        if (!_sharedSingleton)
        {
            _sharedSingleton = [[EventLogStoreCoordinator alloc] init];
        }
        
        return _sharedSingleton;
    }
    
    return nil;
}

+(id)alloc
{
	@synchronized([EventLogStoreCoordinator class])
	{
		NSAssert(_sharedSingleton == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedSingleton = [super alloc];
		return _sharedSingleton;
	}
    
	return nil;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized([EventLogStoreCoordinator class]) {
        NSAssert(_sharedSingleton == nil, @"Attempted to allocate a second instance of a singleton.");
        _sharedSingleton= [super allocWithZone:zone];
        return _sharedSingleton; // assignment and return on first allocation
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone 
{
    return self;
}

- (id)retain 
{
    return self;
}

- (unsigned)retainCount 
{
    return UINT_MAX; //denotes an object that cannot be released
}

- (oneway void)release 
{
    //do nothing
}

- (id)autorelease 
{
    return self;
} 


@end
