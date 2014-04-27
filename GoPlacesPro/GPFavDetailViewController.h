//
//  GPFavDetailViewController.h
//  GoPlacesPro
//
//  Created by Enze Li on 3/19/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import "GPDetailViewController.h"
@import CoreData;

@interface GPFavDetailViewController : GPDetailViewController

@property (strong, nonatomic) NSManagedObject *data;

@end
