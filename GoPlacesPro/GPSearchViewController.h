//
//  GPSearchViewController.h
//  GoPlacesPro
//
//  Created by Enze Li on 3/15/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;
@import MapKit;


@interface GPSearchViewController : UIViewController <CLLocationManagerDelegate, UITextFieldDelegate, MKMapViewDelegate, UITabBarControllerDelegate, UIAlertViewDelegate>

@end
