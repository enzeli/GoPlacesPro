//
//  GPSearchViewController.m
//  GoPlacesPro
//
//  Created by Enze Li on 3/15/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import "GPSearchViewController.h"
#import "GoogleMapsAPI.h"
#import "GPSearchDetailViewController.h"
#import "GooglePlacesSearcher.h"

@interface GPSearchViewController ()
@property (weak, nonatomic) IBOutlet UITextField *locationText;
@property (weak, nonatomic) IBOutlet UITextField *radiusText;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (assign) CLLocationCoordinate2D currentLocation;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic) UIButton *instructionButton;
@property (nonatomic) UIDynamicAnimator *animator;
@property (nonatomic) UIGravityBehavior *gravity;
@property (nonatomic) UICollisionBehavior *collision;

@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@property (assign) BOOL shouldUpdateResults;

@end

@implementation GPSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tabBarController.delegate = self;

    self.dataSource = [[NSMutableArray alloc] init];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];

    self.locationText.delegate = self;
    self.radiusText.delegate = self;
    self.mapView.delegate = self;
    

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"dataSource"];
    [defaults synchronize];
    
}

-(void)viewWillAppear:(BOOL)animated{
    // show instruction button if at first load
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"didLoad"]) {
        [self presentInstructionButton];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"didLoad"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

#pragma mark - location manager delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location = locations[0];
    self.currentLocation = location.coordinate;
    [self.locationManager stopUpdatingLocation];
    
    // setting up mapview
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.currentLocation, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    // show current location
    self.mapView.showsUserLocation = YES;
}


- (IBAction)searchButtonPressed:(id)sender {
    // dismiss
    [self.instructionButton removeFromSuperview];
    
    // dismiss keyboard
    [self.view endEditing:YES];
        
    UIButton __block *cancelRequestButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelRequestButton setTitle:@"Cancel request" forState:UIControlStateNormal];
    [cancelRequestButton setFrame:CGRectMake(100.0, 160.0, 120.0, 40.0)];
    [self.view addSubview:cancelRequestButton];
    
    [cancelRequestButton addTarget:self
                            action:@selector(cancelRequestButtonPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge
                              ];
    self.activityIndicator.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    
    [self.view addSubview: self.activityIndicator];
    [self.activityIndicator startAnimating];
    
    // if no cancel button interruption, should update results
    self.shouldUpdateResults = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [GooglePlacesSearcher nearestVenuesForLatLong:self.currentLocation
                                         withinRadius:[self.radiusText.text floatValue]*1609
                                             forQuery:[self.locationText.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]
                                            queryType:@""
                                     googleMapsAPIKey:MAPS_APIKEY
                                     searchCompletion:^(NSMutableArray *results){
                                         
                                         // update results, map and shared data source
                                         if (self.shouldUpdateResults) {
                                             [self.dataSource removeAllObjects];
                                             [self.dataSource addObjectsFromArray:results];
                                             [self refreshMapview];
                                             [self updateDefaults];
                                         }
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             
                                             
                                             [cancelRequestButton removeFromSuperview];
                                             
                                             [self.activityIndicator stopAnimating];
                                             [self.activityIndicator removeFromSuperview];
                                         });
                                         
                                     }];

    });
    
    
    
}


-(void)cancelRequestButtonPressed:(id)sender
{
    self.shouldUpdateResults = NO;
    [GooglePlacesSearcher cancelAllRequests];
    
    [sender removeFromSuperview];
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    
}


- (void)updateDefaults{
    // sort dataSource and put it in standardUserDefaults
    NSArray *sortedData = [self.dataSource sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDictionary *first = (NSDictionary*)a;
        NSDictionary *second = (NSDictionary*)b;
        
        NSNumber *aLat = first[@"geometry"][@"location"][@"lat"];
        NSNumber *aLng = first[@"geometry"][@"location"][@"lng"];
        CLLocation *aLoc = [[CLLocation alloc] initWithLatitude:[aLat doubleValue] longitude:[aLng doubleValue]];
        
        NSNumber *bLat = second[@"geometry"][@"location"][@"lat"];
        NSNumber *bLng = second[@"geometry"][@"location"][@"lng"];
        CLLocation *bLoc = [[CLLocation alloc] initWithLatitude:[bLat doubleValue] longitude:[bLng doubleValue]];
        
        
        CLLocation *currLoc = [[CLLocation alloc] initWithLatitude:self.currentLocation.latitude longitude:self.currentLocation.longitude];
        
        CLLocationDistance aDist = [aLoc distanceFromLocation: currLoc];
        CLLocationDistance bDist = [bLoc distanceFromLocation: currLoc];
        
        if (aDist < bDist) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        if (aDist > bDist) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:sortedData forKey:@"dataSource"];
    [defaults synchronize];
}


#pragma mark - TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;  
    
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"venueAnnotation"];
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    GPSearchDetailViewController *detailVC = [[GPSearchDetailViewController alloc] init];
    
    for (NSDictionary *data in self.dataSource){
        if ([data[@"name"] isEqualToString:view.annotation.title]) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            detailVC = [sb instantiateViewControllerWithIdentifier:@"GPSearchDetailViewController"];
            detailVC.data = data;
        }
    }
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{

    self.currentLocation = mapView.userLocation.coordinate;
    
    // set up mapview
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.currentLocation, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
}

#pragma mark - update mapview
- (void)refreshMapview
{
    float radius = [self.radiusText.text floatValue]*1609;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.currentLocation, radius, radius);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    id userLocation = [self.mapView userLocation];
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.mapView annotations]];
    if (userLocation != nil) {
        [pins removeObject:userLocation]; // avoid removing user location off the map
    }
    [self.mapView removeAnnotations:pins];
    pins = nil;
    

    for (NSDictionary *data in self.dataSource) {
        if (data[@"geometry"][@"location"]) {
            NSNumber *lat = data[@"geometry"][@"location"][@"lat"];
            NSNumber *lng = data[@"geometry"][@"location"][@"lng"];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
            
            MKPointAnnotation *point = [MKPointAnnotation new];
            point.coordinate = coordinate;
            point.title = data[@"name"];
//            point.subtitle = data[@"vicinity"];
            
            NSString *vicinity =  [data[@"formatted_address"] componentsSeparatedByString:@","][0];
            point.subtitle = vicinity;
            
            [self.mapView addAnnotation:point];
            
        }
    }
    
}

#pragma mark - tab bar delegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSInteger tabitem = tabBarController.selectedIndex;
    if (tabitem == 2) {
        [[tabBarController.viewControllers objectAtIndex:tabitem] popToRootViewControllerAnimated:YES];
    }
    
}


# pragma mark - present instructions
- (void) presentInstructionButton{
    
    NSLog(@"Present Instruction.");
    
    self.instructionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.instructionButton setTitle:@"Tour the app" forState:UIControlStateNormal];

    [self.instructionButton setFrame:CGRectMake(100.0, 60.0, 120.0, 40.0) ];
    [self.instructionButton.layer setBorderColor:[[UIColor blueColor] CGColor]];
    [self.instructionButton.layer setBorderWidth:2.0f];
    [self.instructionButton.layer setCornerRadius:4.0f];
    self.instructionButton.backgroundColor = [UIColor whiteColor];
    
    self.instructionButton.hidden = YES;
    
    [self.view addSubview:self.instructionButton];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.gravity = [[UIGravityBehavior alloc] init];
    [self.gravity addItem:self.instructionButton];

    
    self.collision = [[UICollisionBehavior alloc]initWithItems:@[self.instructionButton]];
    
    float bottomDistance = [[UIScreen mainScreen] bounds].size.height - 68;
    CGPoint p1 =  CGPointMake(0, bottomDistance);
    CGPoint p2 =  CGPointMake(640, bottomDistance);;
    
    [self.collision addBoundaryWithIdentifier:@"bottom" fromPoint:p1 toPoint:p2];
    
    double delayInSeconds = 2.0;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.instructionButton.hidden = NO;
        [self.animator addBehavior:self.gravity];
        [self.animator addBehavior:self.collision];
    });
    
    [self.instructionButton addTarget:self
                          action:@selector(showInstructionAlert:)
                forControlEvents:UIControlEventTouchUpInside];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(buttonDragged:)];

    [self.instructionButton addGestureRecognizer:pan];

}

- (IBAction)buttonDragged:(UIPanGestureRecognizer *)sender {
    
    CGPoint translation = [sender translationInView:self.view.window];
    
    sender.view.center = CGPointMake(sender.view.center.x+translation.x, sender.view.center.y+translation.y);
    
    [sender setTranslation:CGPointMake(0, 0) inView:self.view];
    
}

-(void)showInstructionAlert:(id)sender{
    
    [self.instructionButton removeFromSuperview];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Instruction"
                                                        message:@"Search places in search tab. View results in List at the List tab."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Next", nil];
    alertView.delegate = self;
    [alertView show];
}

#pragma mark - alertView delegate action
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *button = [alertView buttonTitleAtIndex:buttonIndex];
    if([button isEqualToString:@"Next"])
    {
        UIAlertView *nextAlertView = [[UIAlertView alloc] initWithTitle:@"Instruction"
                                                            message:@"Save favourite places and view them in Fav tab offine."
                                                           delegate:self
                                                  cancelButtonTitle:@"Gotcha!"
                                                  otherButtonTitles: nil];
        nextAlertView.delegate = self;
        
        [nextAlertView show];

    }
    
}




@end
