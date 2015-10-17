//
//  MapViewController.m
//  nestaway
//
//  Created by Amruthesh C on 17/10/15.
//  Copyright © 2015 Amruthesh C. All rights reserved.
//

#import "MapViewController.h"
#define GETPROPERTYLIST @"http://a88a4240.ngrok.io/"
#define PADDING 70.0f
#define RADIUS 4000

#import "MapMarkerInfoView.h"

@import GoogleMaps;

@interface MapViewController () <GMSMapViewDelegate>
@property (nonatomic, strong) NSMutableData *responseData;
@property (strong, nonatomic) MapMarkerInfoView *infoWindow;
@property (strong, nonatomic) GMSCoordinateBounds *currentBounds;
//@property(nonatomic, retain) CLLocationManager *locationManager;

@end

@implementation MapViewController{
    GMSMapView *mapView;
    GMSCoordinateBounds *bounds;
    NSMutableArray *allLocationArray;
    NSMutableArray *filteredLocationArray;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    bounds = [[GMSCoordinateBounds alloc] init];
    allLocationArray = [[NSMutableArray alloc] init];
    filteredLocationArray = [[NSMutableArray alloc] init];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:12.9667 longitude:77.5667 zoom:12];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    
    mapView.settings.myLocationButton = YES;
    mapView.settings.zoomGestures = YES;
    mapView.settings.rotateGestures = YES;
    mapView.settings.scrollGestures = YES;
    mapView.settings.tiltGestures = YES;
    mapView.settings.compassButton = YES;
    mapView.settings.accessibilityElementsHidden = NO;
    mapView.settings.consumesGesturesInView = NO;
    mapView.delegate = self;
    [mapView setMinZoom: 0.0 maxZoom: 18.0];
    self.view = mapView;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(longPressed:)];
    longPress.delegate = self;
    [self.view addGestureRecognizer:longPress];
    
    [self getPropertyListingData];
    // Do any additional setup after loading the view from its nib.
}

-(void) longPressed:(UILongPressGestureRecognizer*) gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
        CGPoint longPressPoint = [gestureRecognizer locationInView:mapView];
        CLLocationCoordinate2D coordinate = [mapView.projection coordinateForPoint: longPressPoint];
        NSLog(@"%f : %f",coordinate.latitude, coordinate.longitude);
        
        [filteredLocationArray removeAllObjects];
        for (int i = 0; i < [allLocationArray count]; i++) {
            GMSMarker *marker = allLocationArray[i];
            CLLocation *location =[[CLLocation alloc] initWithLatitude:marker.position.latitude longitude:marker.position.longitude];
            CLLocation *loc = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
            CLLocationDistance distanceMeter = [location distanceFromLocation:loc];
            NSLog(@"%f",distanceMeter);

            if(distanceMeter <= RADIUS){
                NSLog(@"%f",distanceMeter);
                [filteredLocationArray addObject:marker];
            }
        }
        [self mapMarkersFromArray:filteredLocationArray];
    }
}

-(void) viewDidLayoutSubviews{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    CGRect viewBounds = self.view.bounds;
    CGFloat topBarOffset = self.topLayoutGuide.length;
    viewBounds.origin.y = topBarOffset * -1;
    self.view.bounds = viewBounds;
    self.navigationController.navigationBar.translucent = NO;
}

-(void) getPropertyListingData{
    NSURL *myUrl = [NSURL URLWithString:GETPROPERTYLIST];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:myUrl];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error) {
         if ([data length] >0 && error == nil){
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self parseResponse:data];
             });
         }
         else if ([data length] == 0 && error == nil){
             NSLog(@"Empty Response!");
         }
         else if (error != nil){
             NSLog(@"Error = %@", error);
         }
    }];
}

-(void) parseResponse:(NSData*) data{
    NSError *error = nil;
    //parsing the JSON response
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    NSArray *housesResults = [jsonObject valueForKey:@"houses"];
    NSLog(@"Showing %lu houses", (unsigned long)[housesResults count]);
    
    if([housesResults count] > 0){
        for (NSDictionary *house in housesResults) {
            [self addMarkerOnTheMap:house];
        }
        [self mapMarkersFromArray:allLocationArray];
        [self adjustBoundsForMaxZoomLevel: bounds];
        self.currentBounds = bounds;
    } else{
        //Can show current location of the user
        self.currentBounds = nil;
    }
}

-(void) addMarkerOnTheMap:(NSDictionary*) house{
    
    NSString *latStr = [house objectForKey:@"lat_double"];
    NSString *longStr = [house objectForKey:@"long_double"];
    double latitude = [latStr doubleValue];
    double longitude = [longStr doubleValue];
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(latitude, longitude);
    
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    marker.title = [house objectForKey:@"title"];
    marker.appearAnimation = YES;
    marker.icon = [UIImage imageNamed:@"marker"];
    [marker setUserData: house];
    
    [allLocationArray addObject:marker];
}

-(void) mapMarkersFromArray:(NSArray*)array{
    [mapView clear];
    for (int i =0 ; i < [array count]; i++) {
        GMSMarker *marker = array[i];
        marker.map = mapView;
        bounds = [bounds includingCoordinate: marker.position];
    }
}

-(UIView *) mapView: (GMSMapView *)mapView markerInfoWindow: (GMSMarker *)googleMarker {
    if (!self.infoWindow) {
        self.infoWindow = [[MapMarkerInfoView alloc] init];
    }
    
    NSDictionary *markerData = [googleMarker userData];
    NSString *titleText = [NSString stringWithFormat:@"%@ %@",[markerData valueForKey:@"bhk_details"], [markerData valueForKey:@"house_type"]];
    NSString *detailText = [NSString stringWithFormat:@"At %@ for Rs.%@",[markerData valueForKey:@"locality"], [markerData valueForKey:@"min_rent"]];
    
    self.infoWindow.titleLabel.text = titleText;
    self.infoWindow.detailLabel.text = detailText;
    return self.infoWindow;
}

-(void) adjustBoundsForMaxZoomLevel: (GMSCoordinateBounds *)finalBounds {
    GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate fitBounds: finalBounds withPadding: PADDING];
    dispatch_async(dispatch_get_main_queue(), ^{
        [mapView animateWithCameraUpdate: cameraUpdate];
    });
}

-(void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation)fromInterfaceOrientation {
    if (self.currentBounds) {
        [self adjustBoundsForMaxZoomLevel: self.currentBounds];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc {
    mapView = nil;
    self.infoWindow = nil;
    self.currentBounds = nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
