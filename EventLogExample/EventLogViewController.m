//
//  ErrorLogViewController.m
//

#import "EventLogViewController.h"
#import "EventLogTableCell.h"
#import "EventItem.h"

#import "EventLogConfigurationViewController.h"

@interface EventLogViewController () <UISearchDisplayDelegate, UISearchBarDelegate>
{    
}


@property (nonatomic, retain) NSArray *fullContent;
@property (nonatomic, retain) NSMutableArray *listContent;
@property (nonatomic, retain) NSMutableArray *filteredListContent;
@property (nonatomic, retain) NSMutableArray *expandedTableCells;

// The saved state of the search UI if a memory warning removed the view.
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;

@end

@implementation EventLogViewController

@synthesize fullContent = _fullContent, listContent = _listContent, filteredListContent = _filteredListContent;
@synthesize savedSearchTerm = _savedSearchTerm, savedScopeButtonIndex = _savedScopeButtonIndex;
@synthesize searchWasActive = _searchWasActive, expandedTableCells = _expandedTableCells;

+ (void)initialize {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    for (int x = EventItemTypeVerbose; x <= EventItemTypeCritical; x++)
    {
        [defaults setObject:@"YES" forKey:[EventLogConfigurationViewController keyForEventType:x]];
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)dealloc
{
    self.expandedTableCells = nil;
    self.listContent = nil;
    self.fullContent = nil;
    self.filteredListContent = nil;
    self.savedSearchTerm = nil;
    self.searchDisplayController.delegate = nil;
    self.searchDisplayController.searchResultsDelegate = nil;
    self.searchDisplayController.searchResultsDataSource = nil;
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Event Log";
    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch 
                                                                             target:self action:@selector(filterButtonTapped)];
    self.navigationItem.rightBarButtonItem = btnItem;
    [btnItem release];
    
    self.expandedTableCells = [[NSMutableArray alloc] initWithCapacity:5];
	
	// restore search settings if they were saved in didReceiveMemoryWarning.
    if (_savedSearchTerm)
	{
        [self.searchDisplayController setActive:_searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:_savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:_savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
	
	self.tableView.scrollEnabled = YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Find the full list of entries
    self.fullContent = [EventItem findAll];
	
	// create a filtered list that will contain products for the search results table.
    self.listContent = [NSMutableArray arrayWithCapacity:[_fullContent count]];
	self.filteredListContent = [NSMutableArray arrayWithCapacity:[_fullContent count]];
    
    for (EventItem *item in _fullContent)
    {
        NSString *key = [EventLogConfigurationViewController keyForEventType:[item.eventType intValue]];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:key])
        {
            [_listContent addObject:item];
        }
    }
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // save the state of the search UI so that it can be restored if the view is re-created
    _searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    _savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) filterButtonTapped
{
    EventLogConfigurationViewController *vc = [[EventLogConfigurationViewController alloc] initWithNibName:@"EventLogConfigurationViewController" 
                                                                                                    bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    navController.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;
    navController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    [self presentModalViewController:navController animated:YES];
    [navController release];
    [vc release];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	/*
	 If the requesting table view is the search display controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
	 */
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [_filteredListContent count];
    }
	else
	{
        return [_listContent count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"eventLogCellID";
	
	EventLogTableCell *cell = (EventLogTableCell *)[tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil)
	{
		cell = [[[EventLogTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellID] autorelease];
	}
	
	/*
	 If the requesting table view is the search display controller's table view, configure the cell using the filtered content, otherwise use the main list.
	 */
	EventItem *item = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        item = [_filteredListContent objectAtIndex:indexPath.row];
    }
	else
	{
        item = [_listContent objectAtIndex:indexPath.row];
    }
	
	[cell setData:item];
    
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (![_expandedTableCells containsObject:indexPath])
    {
        [_expandedTableCells addObject:indexPath];
    } else {
        [_expandedTableCells removeObject:indexPath];
    }
    
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventItem *event = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        event = [_filteredListContent objectAtIndex:indexPath.row];
    }
    else
    {
        event = [_listContent objectAtIndex:indexPath.row];
    }
    CGFloat h = [EventLogTableCell heightForCellWithEvent:event showExpanded:[_expandedTableCells containsObject:indexPath]];
    return h;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        EventItem *item = nil;
        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            item = [_filteredListContent objectAtIndex:indexPath.row];
            [_filteredListContent removeObjectAtIndex:indexPath.row];
        } else {
            item = [_listContent objectAtIndex:indexPath.row];
            [_listContent removeObjectAtIndex:indexPath.row];
        }
        
        [item deleteManagedObject];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[_filteredListContent removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
	for (EventItem *item in _listContent)
	{
		if (!scope || [scope isEqualToString:@"All"] || [item.eventType intValue] == [self.searchDisplayController.searchBar selectedScopeButtonIndex])
		{   
            BOOL result = [item.message rangeOfString:searchText options:NSDiacriticInsensitiveSearch | NSCaseInsensitiveSearch].length > 0;
            BOOL result2 = [item.longMessage rangeOfString:searchText options:NSDiacriticInsensitiveSearch | NSCaseInsensitiveSearch].length > 0;
            BOOL result3 = [item.originatingObjectName rangeOfString:searchText 
                                                             options:NSDiacriticInsensitiveSearch | NSCaseInsensitiveSearch].length > 0;
            
            if (result || result2 || result3 )
			{
				[_filteredListContent addObject:item];
            }
		}
	}
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}
@end
