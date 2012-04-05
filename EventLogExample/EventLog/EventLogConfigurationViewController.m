//
//  EventLogConfigurationViewController.m
//
//

#import "EventLogConfigurationViewController.h"
#import "EventItem.h"

@interface EventLogConfigurationViewController () 

@property (nonatomic, retain) NSMutableArray *listContent;

@end

@implementation EventLogConfigurationViewController
@synthesize listContent = _listContent;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void) dismissButtonTapped
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Event Filter";
    self.tableView.allowsSelection = NO;
    
    self.listContent = [NSMutableArray arrayWithObjects:@"Verbose", @"Info", @"Debug", @"Warning", @"Error", @"Critical", nil];
    
    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                             target:self action:@selector(dismissButtonTapped)];
    self.navigationItem.rightBarButtonItem = btnItem;
    [btnItem release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.listContent = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
    {
        return [_listContent count];
    }
    else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EventConfigCell";
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UISwitch *swtch = [[UISwitch alloc] init];
            cell.accessoryView = swtch;
            [swtch addTarget:self action:@selector(filterSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
            [swtch release];
        }
        
        // Configure the cell...
        cell.textLabel.text = [_listContent objectAtIndex:indexPath.row];
        
        UISwitch *swtch = (UISwitch *)cell.accessoryView;
        swtch.on = [[NSUserDefaults standardUserDefaults] boolForKey:[EventLogConfigurationViewController keyForEventType:indexPath.row]];
        swtch.tag = indexPath.row;
    } else {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        if (indexPath.row == 0)
        {
            return cell;
        }
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = cell.contentView.bounds;
        [btn setTitle:@"Clear All Events" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor redColor];
        btn.titleLabel.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:btn];
        
        // Configure the action of tapping inside the button
        [btn addTarget:self action:@selector(clearButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

- (void) clearButtonTapped:(id)sender
{
    NSArray *arr = [EventItem findAll];
    if (arr && [arr count] > 0)
    {
        for (EventItem *item in arr)
        {
            [item deleteManagedObjectWithSave:NO];
        }
        [(EventItem *)[arr objectAtIndex:0] saveContext];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear Events" message:@"Finished!" 
                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

+ (NSString *) keyForEventType:(int) eventType
{
    return [NSString stringWithFormat:@"%@%d", kEventTypeKey, eventType];
}

- (void) filterSwitchValueChanged:(UISwitch *)sender
{
    NSString *key = [EventLogConfigurationViewController keyForEventType:sender.tag]; 
    
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
