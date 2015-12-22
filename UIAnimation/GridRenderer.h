//
//  GridRenderer.h
//  GridAnimation
//
//  Created by Huang Hongsen on 6/24/15.
//  Copyright (c) 2015 cn.daniel. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface GridRenderer : NSObject<GLKViewDelegate>
@property (nonatomic, strong) EAGLContext *context;

- (void) startTransitionFromView:(UIView *)fromView toView:(UIView *)toView screenScale:(CGFloat)screenScale inView:(UIView *)viewController duration:(NSTimeInterval)duration completion:(void(^)(void))completion;
@end
