//
//  GPDetailViewController.h
//  GoPlacesPro
//
//  Created by Enze Li on 3/15/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

#define IMAGE_WIDTH 200

@interface GPDetailViewController : UIViewController <UIAlertViewDelegate, MKMapViewDelegate>


@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *openLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *favButton;

@property (nonatomic, strong) MKPointAnnotation *annotation;
@property (nonatomic, assign) BOOL isFav;
@property (nonatomic, strong) NSString *venueId;


@end

