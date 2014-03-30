//
//  ViewController.m
//  ReverseGeocoding
//
//  Created by Jian Yao Ang on 3/30/14.
//  Copyright (c) 2014 Jian Yao Ang. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *myLabel;
@property CLLocationManager *locationManager;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations)
    {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000)
        {
            self.myLabel.text = @"Hungry mode...terminated!";
            [self startReverseGeocoding:location];
            [self.locationManager stopUpdatingLocation];
            break;
        }
    }
}

-(void) startReverseGeocoding: (CLLocation*) location
{
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
    {
        self.myLabel.text = [NSString stringWithFormat:@"%@",placemarks.firstObject];
        [self findRestaurant:placemarks.firstObject];
    }];
}

-(void) findRestaurant: (CLPlacemark*) placemark
{
    self.title = @"Food glorious food";
    MKLocalSearchRequest *localSearchRequest = [MKLocalSearchRequest new];
    localSearchRequest.naturalLanguageQuery = @"Sushi";
    localSearchRequest.region = MKCoordinateRegionMake(placemark.location.coordinate, MKCoordinateSpanMake(1, 1));
    
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:localSearchRequest];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
    {
        NSArray *mapItems = response.mapItems;
        MKMapItem *mapItemFirstObject = mapItems.firstObject;
        self.myLabel.text = [NSString stringWithFormat:@"You might wanna check-out %@", mapItemFirstObject];
        [self directionsToRestaurant:mapItemFirstObject];
    }];
}

-(void) directionsToRestaurant: (MKMapItem*) destinationMapItem
{
    MKDirectionsRequest *directionRequest = [MKDirectionsRequest new];
    directionRequest.source = [MKMapItem mapItemForCurrentLocation];
    directionRequest.destination = destinationMapItem;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
    {
        MKRoute *route = response.routes.firstObject;
        
        for (MKRoute *route in response.routes)
        {
            NSLog(@"Expected time travel is %f", [route expectedTravelTime]);
        }
        
        self.myLabel.text = @"";
        
        for (MKRouteStep *step in route.steps)
        {
            self.myLabel.text = [NSString stringWithFormat:@"%@\n%@",self.myLabel.text,step.instructions];
        }
    }];
}

-(IBAction)updatingUserLocation:(UIButton*)sender
{
    [self.locationManager startUpdatingLocation];
}

@end
