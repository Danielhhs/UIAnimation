//
//  BlindRenderer.h
//  BlindAnimation
//
//  Created by Huang Hongsen on 6/7/15.
//  Copyright (c) 2015 cn.daniel. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NSBKeyframeAnimationFunctions.h"
#import "BlindsMesh.h"
@interface BlindsRenderer : NSObject<GLKViewDelegate>

@property (nonatomic, strong) EAGLContext *context;

- (void) transitionFromView:(UIView *)fromView
                     toView:(UIView *)toView
           inViewController:(UIViewController *)viewController
                columnCount:(NSInteger)columnCount
                   duration:(NSTimeInterval)duration;

- (void) transitionFromView:(UIView *)fromView
                     toView:(UIView *)toView
           inViewController:(UIViewController *)viewController
                columnCount:(NSInteger)columnCount
                   duration:(NSTimeInterval)duration
                 completion:(void(^)(void))completion;

- (void) transitionFromView:(UIView *)fromView
                     toView:(UIView *)toView
           inViewController:(UIViewController *)viewController
                columnCount:(NSInteger)columnCount
                  direction:(BlindsDirection)direction
                   duration:(NSTimeInterval)duration;

- (void) transitionFromView:(UIView *)fromView
                     toView:(UIView *)toView
           inViewController:(UIViewController *)viewController
                columnCount:(NSInteger)columnCount
                  direction:(BlindsDirection)direction
                   duration:(NSTimeInterval)duration
                 completion:(void(^)(void))completion;

- (void) transitionFromView:(UIView *)fromView
                     toView:(UIView *)toView
           inViewController:(UIViewController *)viewController
                columnCount:(NSInteger)columnCount
                  direction:(BlindsDirection)direction
                   duration:(NSTimeInterval)duration
               interpolator:(NSBKeyframeAnimationFunction)interpolator
                 completion:(void(^)(void))completion;
@end
