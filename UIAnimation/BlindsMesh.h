//
//  BlindsMesh.h
//  BlindAnimation
//
//  Created by Huang Hongsen on 6/10/15.
//  Copyright (c) 2015 cn.daniel. All rights reserved.
//

#import "SceneMesh.h"


typedef NS_ENUM(NSInteger, BlindsDirection) {
    BlindsDirectionRightToLeft = 0,
    BlindsDirectionLeftToRight = 1,
};
@interface BlindsMesh : SceneMesh

- (void) drawColumnAtIndex:(NSInteger)index;
- (void) updateWithRotation:(GLfloat)rotation;
- (instancetype) initWithScreenWidth:(size_t)screenWidth
                        screenHeight:(size_t)screenHeight
                             columns:(GLuint)columnCount
                           direction:(BlindsDirection)direction;

@end
