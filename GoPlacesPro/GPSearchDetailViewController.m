//
//  GPSearchDetailViewController.m
//  GoPlacesPro
//
//  Created by Enze Li on 3/19/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import "GPSearchDetailViewController.h"
#import "GoogleMapsAPI.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface GPSearchDetailViewController ()

@end

@implementation GPSearchDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.venueId = self.data[@"id"];
    self.title = self.data[@"name"];
    
    // set restaurant info labels
    NSString *price = self.data[@"price_level"] ? self.data[@"price_level"] : @"unknown";
    self.priceLabel.text = [NSString stringWithFormat:@"Price: %@", [@"" stringByPaddingToLength:[price integerValue] withString:@"$" startingAtIndex:0 ]];
    NSString *rating = self.data[@"rating"] ? self.data[@"rating"] : @"unknown";
    self.ratingLabel.text = [NSString stringWithFormat:@"Rate: %@", rating];
    
    self.openLabel.text = [NSString stringWithFormat:@"Open now: %@",
                           self.data[@"opening_hours"][@"open_now"] ? @"YES" : @"NO"];
    self.typeLabel.text = [NSString stringWithFormat:@" %@", self.data[@"types"][0]];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *photoreference = self.data[@"photos"][0][@"photo_reference"];
    if (photoreference) {
        NSString *urlFormat = @"https://maps.googleapis.com/maps/api/place/photo?maxwidth=%d&photoreference=%@&sensor=true&key=%@";
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:urlFormat, IMAGE_WIDTH, photoreference, MAPS_APIKEY]];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
    NSNumber *lat = self.data[@"geometry"][@"location"][@"lat"];
    NSNumber *lng = self.data[@"geometry"][@"location"][@"lng"];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = coordinate;
    point.title = self.data[@"name"];

    NSString *vicinity =  [self.data[@"formatted_address"] componentsSeparatedByString:@","][0];
    point.subtitle = vicinity;
    
    self.annotation = point;
    [super viewWillAppear:animated];
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
