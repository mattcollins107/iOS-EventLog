//
//  ErrorLogTableCell.h
//

#import <UIKit/UIKit.h>
#import "EventItem.h"

@interface EventLogTableCell : UITableViewCell 

+ (CGFloat) heightForCellWithEvent:(EventItem *)event showExpanded:(BOOL)expanded;

- (void) setData:(EventItem *)event;
- (UIImage *) imageForEvent:(EventItemType) eventType;

@end
