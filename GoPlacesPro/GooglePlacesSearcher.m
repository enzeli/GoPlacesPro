//
//  GooglePlacesSearcher.m
//  GoPlacesPro
//
//  Created by Enze Li on 3/26/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import "GooglePlacesSearcher.h"
#import "AFNetworking.h"

@interface GooglePlacesSearcher()

//@property (nonatomic, strong) NSMutableData *responseData;

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@end

@implementation GooglePlacesSearcher

+ (void)nearestVenuesForLatLong:(CLLocationCoordinate2D)location withinRadius:(float)radius forQuery:(NSString *)query queryType:(NSString *)type googleMapsAPIKey:(NSString *)apikey searchCompletion:(void (^)(NSMutableArray *results))completion
{
    
    NSString *requestFormat = @"https://maps.googleapis.com/maps/api/place/textsearch/json?sensor=true&location=%lf,%lf&radius=%f&query=%@&types=%@&key=%@";
    NSString *requestString = [NSString stringWithFormat:requestFormat,(double)location.latitude, (double)location.longitude, radius, query, type, apikey];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [manager GET:requestString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *data = [responseObject objectForKey:@"results"];
        
        if (completion) {
            completion(data);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Connection Failed"
                                                       message:@"Oops! Check your network configurations."
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles: nil];
        [alert show];
    }];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    
}

+ (void)cancelAllRequests
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.operationQueue cancelAllOperations];
    
}



@end
