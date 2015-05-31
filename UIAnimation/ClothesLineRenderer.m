//
//  ClothesLineRenderer.m
//  ClothesLineAnimation
//
//  Created by Huang Hongsen on 5/23/15.
//  Copyright (c) 2015 cn.daniel. All rights reserved.
//

#import "ClothesLineRenderer.h"
#define kClothesLineAnimationInitalSwingTimeRatio 0.1
#define kClothesLineAnimationInitalSwingMaxTime 0.5
#define kClothesLineAnimationTransitionTimeRatio 0.3
#define kClothesLineAnimationTransitionMaxTime 0.3
#define kClothesLineAnimationSwingAmplitudeAngle (M_PI / 8)
#define kClothesLineAnimationSwingCycle 1.f

@interface ClothesLineRenderer()
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval elapsedTime;
@property (nonatomic, strong) CALayer *currentViewLayer;
@property (nonatomic, strong) CALayer *nextLayer;
@property (nonatomic) CGFloat amplitudeAngle;
@property (nonatomic) CGFloat viewSpace;
@property (nonatomic) NSInteger cycleCount;
@property (nonatomic) NSTimeInterval initialSwingTime;
@property (nonatomic) NSTimeInterval transitionTime;
@property (nonatomic) NSTimeInterval finalSwingTime;
@property (nonatomic) NSTimeInterval swingCycle;
@property (nonatomic) ClothesLineAnimationDirection direction;
@property (nonatomic, strong) void(^completion)(void);
@end

@implementation ClothesLineRenderer

- (void) transitionFromView:(UIView *)fromView toView:(UIView *)toView inViewController:(UIViewController *)viewController direaction:(ClothesLineAnimationDirection)direction duration:(NSTimeInterval)duration completion:(void (^)(void))completion
{
    return [self transitionFromImage:[ClothesLineRenderer snapshotOfView:fromView] toImage:[ClothesLineRenderer snapshotOfView:toView] frame:fromView.frame inViewController:viewController direaction:direction duration:duration completion:completion];
}

- (void) transitionFromImage:(UIImage *)fromImage
                     toImage:(UIImage *)toImage
                       frame:(CGRect)frame
           inViewController:(UIViewController *)viewController
                 direaction:(ClothesLineAnimationDirection)direction
                   duration:(NSTimeInterval)duration
                  completion:(void (^)(void))completion
{
    self.completion = completion;
    self.duration = duration;
    self.direction = direction;
    self.initialSwingTime = duration * kClothesLineAnimationInitalSwingTimeRatio > kClothesLineAnimationInitalSwingMaxTime ? kClothesLineAnimationInitalSwingMaxTime : duration * kClothesLineAnimationInitalSwingTimeRatio;
    self.transitionTime = duration * kClothesLineAnimationTransitionTimeRatio > kClothesLineAnimationTransitionMaxTime ? kClothesLineAnimationTransitionMaxTime : duration * kClothesLineAnimationTransitionTimeRatio;
    self.finalSwingTime = duration - self.initialSwingTime - self.transitionTime;
    self.swingCycle = self.finalSwingTime > kClothesLineAnimationSwingCycle ? kClothesLineAnimationSwingCycle : self.finalSwingTime;
    self.containerView = [[UIView alloc] initWithFrame:frame];
    self.containerView.backgroundColor = [UIColor blackColor];
    CALayer *containerLayer = [CALayer layer];
    containerLayer.frame = self.containerView.bounds;
    
    [self setupCurrentViewLayerWithContainerLayer:containerLayer currentView:fromImage];
    [self setupNextViewLayerWithContainerLayer:containerLayer nextView:toImage];
    
    [self.containerView.layer addSublayer:containerLayer];
    
    [viewController.view addSubview:self.containerView];
    self.elapsedTime = 0.f;
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void) setupCurrentViewLayerWithContainerLayer:(CALayer *)containerLayer currentView:(UIImage *)image
{
    self.currentViewLayer = [CALayer layer];
    self.currentViewLayer.anchorPoint = CGPointMake(0.5, 0);
    self.currentViewLayer.frame = containerLayer.bounds;
    self.currentViewLayer.contents = (__bridge id)image.CGImage;
    [containerLayer addSublayer:self.currentViewLayer];
}

- (void) setupNextViewLayerWithContainerLayer:(CALayer *)containerLayer nextView:(UIImage *)image
{
    self.nextLayer = [CALayer layer];
    self.nextLayer.anchorPoint = CGPointMake(0.5, 0);
    if (self.direction == ClothesLineAnimationDirectionLeftToRight) {
        self.viewSpace = -self.currentViewLayer.frame.size.width * 2;
        self.amplitudeAngle = kClothesLineAnimationSwingAmplitudeAngle;
    } else {
        self.viewSpace = self.currentViewLayer.frame.size.width * 2;
        self.amplitudeAngle = kClothesLineAnimationSwingAmplitudeAngle * -1;
    }
    self.nextLayer.frame = CGRectOffset(self.currentViewLayer.frame, self.viewSpace, 0);
    self.viewSpace *= -1;
    self.nextLayer.contents = (__bridge id)image.CGImage;
    [containerLayer addSublayer:self.nextLayer];
}

- (void) update:(CADisplayLink *)displayLink
{
    self.elapsedTime += displayLink.duration;
    if (self.elapsedTime <= self.initialSwingTime) {
        CGFloat angle = displayLink.duration / (self.initialSwingTime) * self.amplitudeAngle;
        self.currentViewLayer.transform = CATransform3DRotate(self.currentViewLayer.transform, angle, 0, 0, 1);
        self.nextLayer.transform = CATransform3DRotate(self.nextLayer.transform, angle, 0, 0, 1);
    } else if (self.elapsedTime <= (self.initialSwingTime + self.transitionTime)) {
        CGFloat translation = displayLink.duration / self.transitionTime * self.viewSpace;
        CATransform3D transform = CATransform3DMakeTranslation(translation, 0, 0);
        self.currentViewLayer.transform = CATransform3DConcat(self.currentViewLayer.transform, transform);
        self.nextLayer.transform = CATransform3DConcat(self.nextLayer.transform, transform);
    } else if (self.elapsedTime < self.duration) {
        CGFloat swingTime = (self.elapsedTime - self.initialSwingTime - self.transitionTime);
        CGFloat time = swingTime / self.finalSwingTime;
        NSInteger cycles = ceil(self.finalSwingTime / self.swingCycle);
        CGFloat angle = cos(time * (2 * cycles + 1) * M_PI / 2) * self.amplitudeAngle;
        self.nextLayer.transform = CATransform3DRotate(CATransform3DTranslate(CATransform3DIdentity, self.viewSpace, 0, 0), angle, 0, 0, 1);
        if (floor(swingTime / self.swingCycle) > self.cycleCount) {
            self.amplitudeAngle -= (((CGFloat)1 / cycles) * self.amplitudeAngle);
            self.cycleCount++;
        }
    } else {
        self.nextLayer.transform = CATransform3DTranslate(CATransform3DIdentity, self.viewSpace, 0, 0);
        [self.containerView removeFromSuperview];
        if (self.completion) {
            self.completion();
        }
    }

}

+ (UIImage *) snapshotOfView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
