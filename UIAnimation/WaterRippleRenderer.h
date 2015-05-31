//
//  WaterRippleRenderer.h
//  WaterRippleEffect
//
//  Created by Huang Hongsen on 5/27/15.
//  Copyright (c) 2015 Malek Trabelsi. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface WaterRippleRenderer : NSObject<GLKViewDelegate>
@property (nonatomic, strong) EAGLContext *context;

- (void) removeAnimationView;
- (void) initiateRippleAtLocation:(CGPoint)location inViewController:(UIViewController *)viewController fromImage:(UIImage *)fromImage transitionToImage:(UIImage *)toImage duration:(NSTimeInterval)duration completion:(void(^)(void))completion;
@end
