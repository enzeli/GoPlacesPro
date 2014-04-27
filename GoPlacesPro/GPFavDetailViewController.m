//
//  GPFavDetailViewController.m
//  GoPlacesPro
//
//  Created by Enze Li on 3/19/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import "GPFavDetailViewController.h"

@interface GPFavDetailViewController ()

@end

@implementation GPFavDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.venueId = [self.data valueForKey:@"id"];
    self.title = [self.data valueForKey:@"name"];
    
    // set restaurant info labels

    self.priceLabel.text = [self.data valueForKey:@"price"];
    self.ratingLabel.text = [self.data valueForKey:@"rating"];
    self.openLabel.text = @"Favourited";
    self.typeLabel.text = [self.data valueForKey:@"type"];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.imageView setImage:[UIImage imageWithData:[self.data valueForKey:@"imageData"]]];
    
    NSNumber *lat = [self.data valueForKey:@"latitude"];
    NSNumber *lng = [self.data valueForKey:@"longitude"];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = coordinate;
    point.title = [self.data valueForKey:@"name"];
    point.subtitle = [self.data valueForKey:@"vicinity"];
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
