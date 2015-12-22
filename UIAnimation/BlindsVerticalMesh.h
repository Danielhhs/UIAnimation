//
//  BlindsVerticalMesh.h
//  BlindAnimation
//
//  Created by Huang Hongsen on 15/8/3.
//  Copyright (c) 2015年 cn.daniel. All rights reserved.
//

#import "BlindsMesh.h"

@interface BlindsVerticalMesh : BlindsMesh
- (instancetype) initWithScreenWidth:(size_t)screenWidth
                        screenHeight:(size_t)screenHeight
                             rowCount:(GLuint)rowCount
                           direction:(BlindsDirection)direction;

@end
