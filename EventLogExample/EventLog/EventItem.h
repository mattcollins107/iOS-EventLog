//
//  EventItem.h
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    EventItemTypeVerbose = 0,
    EventItemTypeInfo = 1,
    EventItemTypeDebug = 2,
    EventItemTypeWarning = 3,
    EventItemTypeError = 4,
    EventItemTypeCritical = 5
} EventItemType;

@interface EventItem : NSManagedObject {
}
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * eventType;
@property (nonatomic, retain) NSString * longMessage;
@property (nonatomic, retain) NSDate * eventDate;
@property (nonatomic, retain) NSString * originatingObjectName;

// These are convenience methods for managing this NSManagedObject
+ (NSString *) name;
+ (NSManagedObject *) createManagedObject;
+ (NSArray *) findAll;
+ (NSArray *) findWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
+ (NSArray *) defaultSortDescriptors;

// This convenience method can be used to generate a new EventItem based on the parameters.
// The parameter withClass: is used to populate the originatingObjectName by using NSStringFromClass().
+ (void) createEventWithMessage:(NSString *)message withEventType:(EventItemType)type withClass:(Class)clss withLongMessage:(NSString *)longMessage;

- (void) setEventTypeEnum:(EventItemType)type;
- (BOOL) saveContext;
- (BOOL) deleteManagedObject;
- (BOOL) deleteManagedObjectWithSave:(BOOL)save;

@end
