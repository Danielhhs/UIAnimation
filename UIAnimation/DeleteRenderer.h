//
//  DeleteRenderer.h
//  StartAgain
//
//  Created by Huang Hongsen on 5/17/15.
//  Copyright (c) 2015 com.microstrategy. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface DeleteRenderer : NSObject
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKView *animationView;

- (void) deleteView:(UIView *)view
      aniamtionView:(GLKView *)animationView
       withDuration:(NSTimeInterval)duration
            zOffset:(GLfloat)zOffset
         completion:(void(^)(void))completion;
@end
