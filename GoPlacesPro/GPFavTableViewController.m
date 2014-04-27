//
//  GPFavTableViewController.m
//  GoPlacesPro
//
//  Created by Enze Li on 3/19/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import "GPFavTableViewController.h"
#import "GPFavDetailViewController.h"
#import "FavDataManager.h"
@import CoreData;

@interface GPFavTableViewController ()

@property (strong, nonatomic) NSArray *dataSource;

@end

@implementation GPFavTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self fetchFavourites];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    // Refetch results only when there is an update to coredata
    if ([[FavDataManager sharedInstance] hasUpdated]){
        [self fetchFavourites];
   }
    
    // if no data available to show, ask if go back to search
    if ([self.dataSource count] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No favourites found"
                                                            message:@"Go to Places Search?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Go", nil];
        alertView.delegate = self;
        [alertView show];
        
    }
    
}

- (void)fetchFavourites{
    FavDataManager *manager = [FavDataManager sharedInstance];
    NSManagedObjectContext *context = [manager mainObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Venue" inManagedObjectContext:context];
    [request setEntity:entityDescription];
    [request setPredicate:nil];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    self.dataSource = results;
    
//    NSLog(@"%d results fetched.", results.count);
    [self.tableView reloadData];
    
}

#pragma mark - alertView delegate action
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *button = [alertView buttonTitleAtIndex:buttonIndex];
    if([button isEqualToString:@"Go"])
    {
        self.tabBarController.selectedViewController
        = [self.tabBarController.viewControllers objectAtIndex:0];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSource count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoritedVenueCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.dataSource[indexPath.row] valueForKey:@"name"];
    cell.detailTextLabel.text = [self.dataSource[indexPath.row] valueForKey:@"vicinity"];
    
    
    return cell;
}


#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"PushFavDetailSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[GPFavDetailViewController class]]){
            NSIndexPath * indexPath = [self.tableView indexPathForCell:sender];
            GPFavDetailViewController *receiver = (GPFavDetailViewController *)segue.destinationViewController;
            receiver.data = self.dataSource[indexPath.row];
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
