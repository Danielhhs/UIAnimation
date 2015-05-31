//
//  SwitchRenderer.m
//  SwitchAnimation
//
//  Created by Huang Hongsen on 5/28/15.
//  Copyright (c) 2015 cn.daniel. All rights reserved.
//

#import "SwitchRenderer.h"
#import "OpenGLHelper.h"
@interface SwitchRenderer ()
@property (nonatomic, strong) CALayer *containerLayer;
@property (nonatomic, strong) CALayer *fromLayer;
@property (nonatomic, strong) CALayer *toLayer;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, strong) void(^completion)(void);
@end

@implementation SwitchRenderer

- (void) switchFromView:(UIView *)fromView toView:(UIView *)toView inContainerView:(UIView *)containerView duration:(NSTimeInterval)duration completion:(void (^)(void))completion
{
    [self switchFromImage:[OpenGLHelper highResolutionSnapshotForView:fromView] toImage:[OpenGLHelper highResolutionSnapshotForView:toView] inContainerView:containerView duration:duration completion:completion];
}

- (void) switchFromImage:(UIImage *)fromImage toImage:(UIImage *)toImage inContainerView:(UIView *)containerView duration:(NSTimeInterval)duration completion:(void (^)(void))completion
{
    self.duration = duration;
    self.completion = completion;
    [self setupContextWithContainerView:containerView fromImage:fromImage toImage:toImage];
    [self setupFromViewAnimation];
    [self setupToViewAnimation];
}

- (void)setupFromViewAnimation
{
    CAKeyframeAnimation *fromLayerKeyFrame = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    CATransform3D mediumValue;
    if (self.containerLayer.frame.size.width < self.containerLayer.frame.size.height) {
        mediumValue = CATransform3DTranslate(CATransform3DIdentity, self.fromLayer.frame.size.width * (sqrt(2) - 1) / 2, 0, 0);
        mediumValue = CATransform3DRotate(mediumValue, M_PI / 4, 0, 0, 1);
    } else {
        mediumValue = CATransform3DTranslate(CATransform3DIdentity, 0, self.fromLayer.frame.size.height * (sqrt(2) - 1) / 2, 0);
        mediumValue = CATransform3DRotate(mediumValue, -M_PI / 4, 0, 0, 1);
    }
    fromLayerKeyFrame.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity], [NSValue valueWithCATransform3D:mediumValue], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    fromLayerKeyFrame.duration = self.duration;
    [self.fromLayer addAnimation:fromLayerKeyFrame forKey:@""];
}

- (void) setupToViewAnimation
{
    CAKeyframeAnimation *toLayerKeyFrame = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    CATransform3D mediumValue;
    if (self.containerLayer.frame.size.width < self.containerLayer.frame.size.height) {
        mediumValue = CATransform3DTranslate(CATransform3DIdentity, -self.fromLayer.frame.size.width * (sqrt(2) - 1) / 2, 0, 0);
        mediumValue = CATransform3DRotate(mediumValue, -M_PI / 4, 0, 0, 1);
    } else {
        mediumValue = CATransform3DTranslate(CATransform3DIdentity, 0, -self.fromLayer.frame.size.height * (sqrt(2) - 1) / 2, 0);
        mediumValue = CATransform3DRotate(mediumValue, M_PI / 4, 0, 0, 1);
    }
    toLayerKeyFrame.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity], [NSValue valueWithCATransform3D:mediumValue], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    toLayerKeyFrame.duration = self.duration;
    
    CAKeyframeAnimation *toLayerZPositionKeyFrame = [CAKeyframeAnimation animationWithKeyPath:@"zPosition"];
    toLayerZPositionKeyFrame.values = @[@(-10), @(0), @(0)];
    toLayerZPositionKeyFrame.duration = self.duration;
    
    CAAnimationGroup *toLayerAnimations = [CAAnimationGroup animation];
    toLayerAnimations.animations = @[toLayerKeyFrame, toLayerZPositionKeyFrame];
    toLayerAnimations.duration = self.duration;
    toLayerAnimations.delegate = self;
    [self.toLayer addAnimation:toLayerAnimations forKey:@""];
    self.toLayer.zPosition = 0;
}

- (void) setupContextWithContainerView:(UIView *)containerView fromImage:(UIImage *)fromImage toImage:(UIImage *)toImage
{
    self.containerLayer = [CALayer layer];
    self.containerLayer.frame = containerView.bounds;
    self.containerLayer.backgroundColor = [UIColor blackColor].CGColor;
    [containerView.layer addSublayer:self.containerLayer];
    
    self.toLayer = [CALayer layer];
    if (containerView.frame.size.width < containerView.frame.size.height) {
        self.toLayer.anchorPoint = CGPointMake(0, 1);
    } else {
        self.toLayer.anchorPoint = CGPointMake(1, 0);
    }
    self.toLayer.frame = self.containerLayer.bounds;
    self.toLayer.contents = (__bridge id)toImage.CGImage;
    self.toLayer.zPosition = -10;
    [self.containerLayer addSublayer:self.toLayer];
    
    self.fromLayer = [CALayer layer];
    self.fromLayer.anchorPoint = CGPointMake(1, 1);
    self.fromLayer.frame = self.containerLayer.bounds;
    self.fromLayer.zPosition = - 1;
    self.fromLayer.contents = (__bridge id)fromImage.CGImage;
    [self.containerLayer addSublayer:self.fromLayer];
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.containerLayer removeFromSuperlayer];
    if (self.completion) {
        self.completion();
    }
}

@end
