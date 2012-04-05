//
//  EventLogDefinitions.h
//
#import "EventItem.h"
#import "EventLogViewController.h"

#	define DebugLog(fmt, ...) [EventItem createEventWithMessage:[NSString stringWithFormat:fmt, ##__VA_ARGS__] withEventType:EventItemTypeDebug withClass:[self class] withLongMessage:nil];
#   define VerboseLog(msg, fmt, ...) [EventItem createEventWithMessage:[NSString stringWithFormat:fmt, ##__VA_ARGS__] withEventType:EventItemTypeVerbose withClass:[self class] withLongMessage:msg];
#   define ErrorLog(exception, fmt, ...) [EventItem createEventWithMessage:[NSString stringWithFormat:fmt, ##__VA_ARGS__] withEventType:EventItemTypeError withClass:[self class] withLongMessage:[NSString stringWithFormat:@"Exception: %@ - %@", [exception name], [exception reason]]];
#   define InfoLog(msg, fmt, ...) [EventItem createEventWithMessage:[NSString stringWithFormat:fmt, ##__VA_ARGS__] withEventType:EventItemTypeInfo withClass:[self class] withLongMessage:msg];
#   define CriticalLog(msg, fmt, ...) [EventItem createEventWithMessage:[NSString stringWithFormat:fmt, ##__VA_ARGS__] withEventType:EventItemTypeCritical withClass:[self class] withLongMessage:msg];
#   define WarningLog(msg, fmt, ...) [EventItem createEventWithMessage:[NSString stringWithFormat:fmt, ##__VA_ARGS__] withEventType:EventItemTypeWarning withClass:[self class] withLongMessage:msg];

