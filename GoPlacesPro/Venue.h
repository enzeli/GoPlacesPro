//
//  Venue.h
//  GoPlacesPro
//
//  Created by Enze Li on 3/19/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Venue : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * price;
@property (nonatomic, retain) NSString * rating;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * vicinity;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;

@end
