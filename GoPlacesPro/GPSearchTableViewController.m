//
//  GPTableViewController.m
//  GoPlacesPro
//
//  Created by Enze Li on 3/15/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import "GPSearchTableViewController.h"
#import "GPSearchDetailViewController.h"


@interface GPSearchTableViewController ()

@property (strong, nonatomic) NSArray *dataSource;

@end

@implementation GPSearchTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}


- (void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
    
    // if no data available to show, ask to go back to search
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"dataSource"] count] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No results found"
                                                            message:@"Go to Places Search?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Go", nil];
        alertView.delegate = self;
        [alertView show];
        
    }
    
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
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"dataSource"] count];;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VenueCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"dataSource"][indexPath.row];
    
    cell.textLabel.text = data[@"name"];
    
    NSString *vicinity =  [data[@"formatted_address"] componentsSeparatedByString:@","][0];
    cell.detailTextLabel.text = vicinity;

    
    return cell;
}


#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"PushDetailSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[GPSearchDetailViewController class]]){
            NSIndexPath * indexPath = [self.tableView indexPathForCell:sender];
            GPSearchDetailViewController *receiver = (GPSearchDetailViewController *)segue.destinationViewController;
            receiver.data = [[NSUserDefaults standardUserDefaults] objectForKey:@"dataSource"][indexPath.row];
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
