//
//  EventItem.m
//  NiscMobile
//

#import "EventItem.h"
#import "EventLogStoreCoordinator.h"

@implementation EventItem
@dynamic message;
@dynamic eventType;
@dynamic longMessage;
@dynamic eventDate;
@dynamic originatingObjectName;

#pragma -
#pragma mark Global Methods
+ (NSString *) name
{
    return @"EventItem";
}

+ (NSManagedObject *) createManagedObject
{
	return [[EventLogStoreCoordinator globalObject] createObjectWithName:[[self class] name]];	
}

+ (void) createEventWithMessage:(NSString *)message withEventType:(EventItemType)type withClass:(Class)clss withLongMessage:(NSString *)longMessage
{
    EventItem *item = (EventItem *)[self createManagedObject];
    
    item.message = message;
    item.eventDate = [NSDate date];
    item.longMessage = longMessage;
    item.originatingObjectName = NSStringFromClass(clss);
    item.eventType = [NSNumber numberWithInt:type];
    
    [item saveContext];
    
    NSLog(@"Message Logged: %@\nFor Class: %@\nLong Message: %@", message, clss, longMessage);
    
}

+ (NSArray *) findAll
{
 
    NSManagedObjectContext *context = [[EventLogStoreCoordinator globalObject] managedObjectContext];
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:[[self class] name] inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
    
    NSArray *sortDescriptors = [self defaultSortDescriptors];
    if (sortDescriptors)
    {
        [fetchRequest setSortDescriptors:sortDescriptors];
    }
    
    // Return the results
    NSError *error = nil;
    return [context executeFetchRequest:fetchRequest error:&error];
}

+ (NSArray *) findWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *ent = [NSEntityDescription entityForName:[[self class] name] inManagedObjectContext:context];
    fetchRequest.entity = ent;
    
    NSError *error = nil;
    fetchRequest.predicate = predicate;
    
    NSArray *sortDescriptors = [self defaultSortDescriptors];
    if (sortDescriptors)
    {
        [fetchRequest setSortDescriptors:sortDescriptors];
    }
    
    NSArray *fetchedItems = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedItems.count != 0) {
        return fetchedItems;
    }
    
    return nil;
}

+ (NSArray *) defaultSortDescriptors
{
    NSSortDescriptor *startDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"eventDate" ascending:NO] autorelease];
	return [NSArray arrayWithObject:startDescriptor];
}

#pragma -
#pragma mark Instance Methods
- (BOOL) saveContext
{
    return [EventLogStoreCoordinator saveContext];
}

- (void) setEventTypeEnum:(EventItemType)type
{
    self.eventType = [NSNumber numberWithInt:type];
}

- (BOOL) deleteManagedObject
{
    return [self deleteManagedObjectWithSave:YES];
}

- (BOOL) deleteManagedObjectWithSave:(BOOL)save
{
    // Delete the managed object.
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:self];
    
    if (save)
    {
        NSError *error;
        if (![context save:&error]) {
            // Update to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            return NO;  // Fail
        }
    }
    return YES;
}


@end
