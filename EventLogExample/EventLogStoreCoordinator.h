//
//  ErrorLogStoreCoordinator.h
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface EventLogStoreCoordinator : NSObject {
    
@private
    NSMutableDictionary *managedObjectContexts_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
    
    
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// Singleton methods
+ (EventLogStoreCoordinator *) globalObject;

// Global methods
+ (BOOL)saveContext;
+ (NSManagedObject *) createObjectWithName:(NSString *)name;

// Instance methods

/**
 *  This method saves the managedObjectContext for the given NSThread, if it exists, and returns whether it was successfully saved or not.  
 *  After saving, the managedObjectContext is then removed from the context cache.  A subsequent call for the thread's context will then create
 *  a new managedObjectContext.
 */
- (BOOL)saveContext;
/**
 *  This method saves the managedObjectContext for the given NSThread, if it exists, and returns whether it was successfully saved or not.
 *  If autoRemove is set to YES, the managedObjectContext is then destroyed.  If it is set to NO, it remains in the context cache tied to that
 *  NSThread and will need to be cleared later.
 */
- (BOOL)saveContextWithAutoContextRemoval:(BOOL)autoRemove;

/** 
 *  Removes the NSThread's managedObjectContext from the context cache, if it exists.  This does not save the managedObjectContext before removing it.
 */
- (BOOL)cleanupForThread:(NSThread *)thread;

/**
 *  This method creates and returns a new NSManagedObject in the managedObjectContext of the current NSThread.
 */ 
- (NSManagedObject *) createObjectWithName:(NSString *)name;

@end
