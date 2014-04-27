//
//  GooglePlacesSearcher.h
//  GoPlacesPro
//
//  Created by Enze Li on 3/26/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface GooglePlacesSearcher : NSObject <NSURLConnectionDelegate>


+ (void) nearestVenuesForLatLong:(CLLocationCoordinate2D)location
                    withinRadius:(float)radius
                        forQuery:(NSString *)query
                       queryType:(NSString *)type
                googleMapsAPIKey:(NSString *)apikey
                searchCompletion:(void (^)(NSMutableArray *results))completion;

+ (void) cancelAllRequests;

@end
