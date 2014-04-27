//
//  GPDetailViewController.m
//  GoPlacesPro
//
//  Created by Enze Li on 3/15/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import "GPDetailViewController.h"
#import "GPAppDelegate.h"
@import CoreData;
#import "Venue.h"
#import "FavDataManager.h"

#define IMAGE_WIDTH 200

@interface GPDetailViewController ()

@end

@implementation GPDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.mapView.delegate = self;
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"texture.jpg"]];
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = [UIImage imageNamed:@"placeholder.jpg"];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
    self.isFav = [self isFavorited];
    if (self.isFav){
        [self.favButton setTitle:@"Unfav" forState:UIControlStateNormal];
    } else {
        [self.favButton setTitle:@"Fav" forState:UIControlStateNormal];
    }
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.annotation.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    //add the pin to the map
    [self.mapView addAnnotation:self.annotation];
    
    // show current location
    self.mapView.showsUserLocation = YES;
    
    //select the last annotation after delay
    double delayInSeconds = 0.88;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.mapView selectAnnotation:self.annotation animated:YES];
    });
    
}

- (BOOL)isFavorited
{
    FavDataManager *manager = [FavDataManager sharedInstance];
    NSManagedObjectContext *context = [manager mainObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Venue" inManagedObjectContext:context];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", self.venueId];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if ([results count] >= 1) {
        if ([results count] > 1){
            NSLog(@"Error:  favs");
        }
        
        return YES;
    } else {
        return NO;
    }
}

- (IBAction)getDirectionButtonPressed:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Get Direction"
                                                        message:@"Go to Maps?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Go", nil];
    alertView.delegate = self;
    [alertView show];
}

- (IBAction)favoriteButtonPressed:(id)sender {
    FavDataManager *manager = [FavDataManager sharedInstance];
    NSManagedObjectContext *context = [manager mainObjectContext];
    
    if (self.isFav) {
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"Venue" inManagedObjectContext:context];
        [request setEntity:entityDescription];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", self.venueId];
        [request setPredicate:predicate];

        NSError *error;
        NSArray *results = [context executeFetchRequest:request error:&error];
        
        
        // should handle error
        for (NSManagedObject *obj in results) {
            [context deleteObject:obj];
        }
        
        [manager save];
        
//        NSLog(@"Deleted fav");
        
        self.isFav = NO;
        [self.favButton setTitle:@"Fav" forState:UIControlStateNormal];
        
    } else {
        
        Venue *venue = [NSEntityDescription insertNewObjectForEntityForName:@"Venue"
                                          inManagedObjectContext:context];
        
        [venue setValue:self.venueId forKey:@"id"];
        venue.name = self.annotation.title;
        venue.vicinity = self.annotation.subtitle;
        venue.price = self.priceLabel.text;
        venue.rating = self.ratingLabel.text;
        venue.type = self.typeLabel.text;
        venue.imageData = UIImagePNGRepresentation(self.imageView.image);
        venue.latitude = [NSNumber numberWithDouble: self.annotation.coordinate.latitude];
        venue.longitude = [NSNumber numberWithDouble: self.annotation.coordinate.longitude];
    
        [manager save];

//        NSLog(@"Added fav");
        
        self.isFav = YES;
        [self.favButton setTitle:@"Unfav" forState:UIControlStateNormal];
    }
    
 
}


#pragma mark - alertView delegate action
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *button = [alertView buttonTitleAtIndex:buttonIndex];
    if([button isEqualToString:@"Go"])
    {
        NSURL *mapsURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/?q=%@",
                                               [self.annotation.subtitle stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
        [[UIApplication sharedApplication] openURL:mapsURL];
    }
    
}


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
