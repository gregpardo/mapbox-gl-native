//
//  MBXEmbededMapViewController.m
//  ios
//
//  Created by David Chiles on 3/7/17.
//  Copyright © 2017 Mapbox. All rights reserved.
//

#import "MBXEmbededMapViewController.h"
#import <Mapbox/Mapbox.h>

typedef NS_ENUM(NSInteger, MBXEmbeddedControl) {
    MBXEmbeddedControlZoom = 0,
    MBXEmbeddedControlScroll,
    MBXEmbeddedControlRotation,
    MBXEmbeddedControlPitch
};


@interface MBXEmbededMapViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) MGLMapView *mapView;

@end

@implementation MBXEmbededMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIRotationGestureRecognizer *gestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotation:)];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    [scrollView addGestureRecognizer:gestureRecognizer];
    
    CGRect mapRect = CGRectMake(0, 0, CGRectGetWidth(scrollView.frame) * 2, CGRectGetHeight(scrollView.frame) * 2);
    self.mapView = [[MGLMapView alloc] initWithFrame:mapRect];
    [scrollView addSubview:self.mapView];
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(mapRect), CGRectGetHeight(mapRect));
    
    CGFloat widthScale = self.view.bounds.size.width / CGRectGetWidth(mapRect);
    CGFloat heightScale = self.view.bounds.size.height / CGRectGetHeight(mapRect);
    CGFloat minScale = MIN(widthScale, heightScale);
    
    scrollView.maximumZoomScale = minScale*10;
    scrollView.minimumZoomScale = minScale;
    
    //Create list of all the possible control titles
    NSMutableArray <UIView*>*items = [[NSMutableArray alloc] init];
    for(NSInteger index =0; index < 4; index++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font = [UIFont systemFontOfSize:12];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.text = [[self class] titleForControl:index];
        UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectZero];
        switchControl.tag = index;
        [switchControl addTarget:self action:@selector(didSwitch:) forControlEvents:UIControlEventValueChanged];
        switchControl.translatesAutoresizingMaskIntoConstraints = NO;
        switchControl.on = [self statusForControl:index];
        [view addSubview:label];
        [view addSubview:switchControl];
        [items addObject:view];
        
        [view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeHeight multiplier:0.5 constant:0.0]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:switchControl attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:switchControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        
    }
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:items];
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.frame), 65);
    
    [self.view addSubview:stackView];
}

- (void)didSwitch:(UISwitch *)sw {
    [self switchContorl:sw.tag];
    if (sw.tag == MBXEmbeddedControlRotation) {
        
    }
}

- (void)rotation:(UIRotationGestureRecognizer *)rotationGesture
{
    self.mapView.transform = CGAffineTransformRotate(rotationGesture.view.transform, rotationGesture.rotation);
}

- (void)switchContorl:(MBXEmbeddedControl) control {
    switch (control) {
        case MBXEmbeddedControlZoom:
            self.mapView.zoomEnabled = !self.mapView.zoomEnabled;
            break;
        case MBXEmbeddedControlScroll:
            self.mapView.scrollEnabled = !self.mapView.scrollEnabled;
            break;
        case MBXEmbeddedControlRotation:
            self.mapView.rotateEnabled = !self.mapView.rotateEnabled;
            break;
        case MBXEmbeddedControlPitch:
            self.mapView.pitchEnabled = !self.mapView.pitchEnabled;
            break;
    }
}

- (BOOL)statusForControl:(MBXEmbeddedControl) control {
    switch (control) {
        case MBXEmbeddedControlZoom:
            return self.mapView.zoomEnabled;
        case MBXEmbeddedControlScroll:
            return self.mapView.scrollEnabled;
        case MBXEmbeddedControlRotation:
            return self.mapView.rotateEnabled;
        case MBXEmbeddedControlPitch:
            return self.mapView.pitchEnabled;
    }
}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.mapView;
}

#pragma mark Class method


+ (NSString *)titleForControl:(MBXEmbeddedControl) control {
    switch (control) {
        case MBXEmbeddedControlZoom:
            return @"Zoom Enabled";
        case MBXEmbeddedControlScroll:
            return @"Scroll Enabled";
            break;
        case MBXEmbeddedControlRotation:
            return @"Rotation Enabled";
            break;
        case MBXEmbeddedControlPitch:
            return @"Pitch Enabled";
            break;
    }
}

@end
