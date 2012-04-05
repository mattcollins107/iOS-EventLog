//
//  ErrorLogTableCell.m
//
//  Created by Matthew Collins on 5/17/11.
//  Copyright 2011. All rights reserved.
//

#import "EventLogTableCell.h"

#define CELL_CONTENT_HEIGHT 44.0f
#define CELL_CONTENT_WIDTH 318.0f
#define CELL_CONTENT_MARGIN 5.0f
#define kVerticalMarginThin 2
#define kVerticalMargin 5
#define kMessageLabelTop 26
#define kImageViewWidth 30

@interface EventLogTableCell () {
    UILabel *_longMessageLbl;
    UILabel *_originatingClassLbl;
    
    EventItem *_event;
}
@end

@implementation EventLogTableCell

+ (CGFloat) heightForCellWithEvent:(EventItem *)event showExpanded:(BOOL)expanded
{
    // Calculate the height of the cell given the content in 'event'
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 3) - kImageViewWidth, 20000.0f);    
    CGSize msgSize = [event.message sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]] 
                             constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    if (expanded)
    {
        CGSize size = [event.longMessage sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]] 
                                    constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        return MAX(size.height + msgSize.height + 3 * kVerticalMargin + CELL_CONTENT_HEIGHT, CELL_CONTENT_HEIGHT);
    } else {
        return MAX(msgSize.height - kMessageLabelTop + 3 * kVerticalMargin + CELL_CONTENT_HEIGHT, CELL_CONTENT_HEIGHT);
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        
        if (style == UITableViewStylePlain)
        {
            self.backgroundColor = [UIColor whiteColor];
        }
        
        // Initialization code
        _originatingClassLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        _originatingClassLbl.backgroundColor = [UIColor clearColor];
        _originatingClassLbl.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        [[self contentView] addSubview:_originatingClassLbl];
        
        _longMessageLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        _longMessageLbl.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        _longMessageLbl.backgroundColor = [UIColor clearColor];
        _longMessageLbl.numberOfLines = 0;
        _longMessageLbl.lineBreakMode = UILineBreakModeWordWrap;
        [[self contentView] addSubview:_longMessageLbl];
        
        [self.textLabel setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth];
        [self.detailTextLabel setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth];

        self.clipsToBounds = YES;
        
        self.accessoryType = UITableViewCellAccessoryNone;
        
        UILongPressGestureRecognizer *gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDetected:)];
        gr.allowableMovement = 5.0;
        [self addGestureRecognizer:gr];
        [gr release];
    }
    return self;
}

- (void) longPressDetected:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [NSString stringWithFormat:@"%@\n%@\n%@\n%@", self.textLabel.text, self.detailTextLabel.text, 
                             _originatingClassLbl.text, _longMessageLbl.text];
    }
}

- (void)dealloc
{
    [_originatingClassLbl release];
    [_longMessageLbl release];
    [super dealloc];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    CGRect i = self.imageView.frame;
    i.origin.y = kVerticalMargin;
    self.imageView.frame = i;
    
    CGRect f = self.textLabel.frame;
    f.origin.y = kVerticalMarginThin;
    self.textLabel.frame = f;
    
    float top = f.origin.y + f.size.height + kVerticalMarginThin;
    f = self.detailTextLabel.frame;
    f.origin.y = top;
    self.detailTextLabel.frame = f;
    
    // Prepare the frame for the added labels
    f.origin.x = CELL_CONTENT_MARGIN;
    f.origin.y += f.size.height + kVerticalMargin;
    f.size.width = CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2);
    
    // Set the originating class label frame
    _originatingClassLbl.frame = f;
    f.origin.y += f.size.height + kVerticalMargin;
    
    // Set the long message label frame
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 3) - kImageViewWidth, 20000.0f);
    CGSize size = [_longMessageLbl.text sizeWithFont:_longMessageLbl.font 
                                constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    f.size.height = size.height;
    _longMessageLbl.frame = f;
}

- (void) setData:(EventItem *)event
{
    NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:@"MM/dd/yyyy hh:mm:ss"];
    
    _event = event; // Note this is an assignment
    self.textLabel.text = [formatter stringFromDate:event.eventDate];
    self.detailTextLabel.text = event.message;
    _longMessageLbl.text = event.longMessage;
    _originatingClassLbl.text = [NSString stringWithFormat:@"Originating Class: %@", event.originatingObjectName];
    
    self.imageView.image = [self imageForEvent:[event.eventType intValue]];
}

- (UIImage *) imageForEvent:(EventItemType) eventType
{
    NSString *symbol = @"U";
    UIColor *bgColor = nil;
    UIColor *textColor = [UIColor whiteColor];
    
    switch (eventType) {
        case EventItemTypeInfo:
            symbol = @"In";
            bgColor = [UIColor darkGrayColor];
            break;
        case EventItemTypeVerbose:
            symbol = @"Ve";
            bgColor = [UIColor greenColor];
            break;
        case EventItemTypeWarning:
            symbol = @"Wa";
            bgColor = [UIColor blueColor];
            break;
        case EventItemTypeError:
            symbol = @"Er";
            bgColor = [UIColor orangeColor];
            break;
        case EventItemTypeCritical:
            symbol = @"Cr";
            bgColor = [UIColor redColor];
            break;
        case EventItemTypeDebug:
            symbol = @"De";
            bgColor = [UIColor grayColor];
            break;
        default:
            break;
    }
    
    // return a 30 x 30 image to display as the event icon
	CGSize itemSize=CGSizeMake(kImageViewWidth,kImageViewWidth);
	UIGraphicsBeginImageContext(itemSize);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Fill the background
    CGRect symbolRectangle = CGRectMake(0,0, itemSize.width, itemSize.height);
    CGContextSetFillColorWithColor(context, [bgColor CGColor]);
    CGContextFillRect(context, symbolRectangle);
    
	// Draw the symbol
	[textColor set];
	UIFont *font = [UIFont boldSystemFontOfSize:20];
	CGSize stringSize = [symbol sizeWithFont:font];
	CGPoint point = CGPointMake((symbolRectangle.size.width-stringSize.width)/2,5);
	
	[symbol drawAtPoint:point withFont:font];
	
	UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return theImage;
}

@end
