//
//  IIViewController.m
//  ScrollKit
//
//  Created by Fille Åström on 20/11/13.
//

#import "IIViewController.h"
#import "IIMyScene.h"

static NSString * kViewTransformChanged = @"view transform changed";

@interface IIViewController ()

@property(nonatomic, weak)IIMyScene *scene;
@property(nonatomic, weak)UIView *clearContentView;

@end

@implementation IIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;

    // Create and configure the scene.
    IIMyScene *scene = [IIMyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeResizeFill;

    // Present the scene.
    [skView presentScene:scene];
    _scene = scene;

    CGSize contentSize = skView.frame.size;
    const CGFloat multiplier = 1.5;
    contentSize.height *= multiplier;
    [scene setContentSize:contentSize];


    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [scrollView setDelegate:self];
    [scrollView setMinimumZoomScale:1.0];
    [scrollView setMaximumZoomScale:3.0];
    [scrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    UIView *clearContentView = [[UIView alloc] initWithFrame:(CGRect){.origin = CGPointZero, .size = contentSize}];
    [clearContentView setBackgroundColor:[UIColor clearColor]];
    [scrollView setContentSize:contentSize];
    [scrollView addSubview:clearContentView];

    _clearContentView = clearContentView;

    [clearContentView addObserver:self
                       forKeyPath:@"transform"
                          options:NSKeyValueObservingOptionNew
                          context:&kViewTransformChanged];
    [skView addSubview:scrollView];

    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(scrollView, clearContentView);
    [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [skView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:0 views:viewsDictionary]];
    [skView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:0 views:viewsDictionary]];
}

-(void)adjustContent:(UIScrollView *)scrollView
{
    CGFloat zoomScale = [scrollView zoomScale];
    [self.scene setContentScale:zoomScale];
    CGPoint contentOffset = [scrollView contentOffset];
    [self.scene setContentOffset:contentOffset];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self adjustContent:scrollView];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.clearContentView;
}

-(void)scrollViewDidTransform:(UIScrollView *)scrollView
{
    [self adjustContent:scrollView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale; // scale between minimum and maximum. called after any 'bounce' animations
{
    [self adjustContent:scrollView];
}
#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if (context == &kViewTransformChanged)
    {
        [self scrollViewDidTransform:(id)[(UIView *)object superview]];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)dealloc
{
    @try {
        [self.clearContentView removeObserver:self forKeyPath:@"transform"];
    }
    @catch (NSException *exception) {    }
    @finally {    }
}

@end
