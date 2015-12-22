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
    BlindsDirectionTopToBottom = 2,
    BlindsDirectionBottomToTop = 3
};
@interface BlindsMesh : SceneMesh

- (void) drawColumnAtIndex:(NSInteger)index;
- (void) updateWithRotation:(GLfloat)rotation;

@end
