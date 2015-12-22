//
//  SpinRenderer.h
//  SpinAnimation
//
//  Created by Huang Hongsen on 5/19/15.
//  Copyright (c) 2015 cn.daniel. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface SpinRenderer : NSObject<GLKViewDelegate>

@property (nonatomic, strong) EAGLContext *context;

- (void) spinFromView:(UIView *)fromView
               toView:(UIView *)toView
          screenScale:(CGFloat)screenScale
        animationView:(GLKView *)animationView
             duration:(NSTimeInterval)duration
                angle:(GLfloat)angle
              zOffset:(GLfloat)zoffset
           completion:(void(^)(void))completion;

@end
