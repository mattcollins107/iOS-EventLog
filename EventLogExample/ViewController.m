//
//  ViewController.m
//  EventLogExample
//
//  Created by Matthew Collins on 4/3/12.
//  Copyright (c) 2012 NISC. All rights reserved.
//

#import "ViewController.h"
#import "EventLogDefinitions.h"

@implementation ViewController

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Event Log Example";
}


#pragma mark - Actions

- (IBAction)postEvent:(id)sender
{
    DebugLog(@"%@", @"This is a generic debug log.");
}

- (IBAction)postVerboseEvent:(id)sender
{
    VerboseLog(@"This is a longer message indicating more information about the event that is being recorded.",
               @"%@", @"This is a verbose log.");
}

- (IBAction)postWarningEvent:(id)sender
{
    // Notice that these logging methods all support a stringFromFormat based method for building 
    // event titles.
    WarningLog(@"This warning log can have more information describing the warning.", @"%@ %@ %@", @"Warning: ",
               @"Unexpected event has ", @"potentially occurred.");
}

- (IBAction)postExceptionEvent:(id)sender
{
    static int i = 0;
    NSException *exception = [NSException exceptionWithName:@"Exception Name" 
                                                     reason:@"Exception Reason" 
                                                   userInfo:nil];
    ErrorLog(exception, @"%@ %d %@", @"Exception has occurred", ++i, @"times");
}

- (IBAction)postInfoEvent:(id)sender
{
    InfoLog(@"This is a simple informational statement.", @"%@", @"Information Log");
}

- (IBAction)postCriticalEvent:(id)sender
{
    CriticalLog(@"Events can have different levels of priority.", @"%@", @"Critical Message!");
}

- (IBAction)viewEventLog:(id)sender
{
    EventLogViewController *vc = [[EventLogViewController alloc] initWithNibName:@"EventLogViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

@end
