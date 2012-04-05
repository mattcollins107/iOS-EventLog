//
//  EventLogConfigurationViewController.h
//

#import <UIKit/UIKit.h>

#define kEventTypeKey @"filterEventItemType"

@interface EventLogConfigurationViewController : UITableViewController 

+ (NSString *) keyForEventType:(int) eventType;

@end
