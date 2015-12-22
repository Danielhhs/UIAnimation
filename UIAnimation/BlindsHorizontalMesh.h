//
//  BlindsHorizontalMesh.h
//  BlindAnimation
//
//  Created by Huang Hongsen on 15/8/3.
//  Copyright (c) 2015年 cn.daniel. All rights reserved.
//

#import "BlindsMesh.h"

@interface BlindsHorizontalMesh : BlindsMesh

- (instancetype) initWithScreenWidth:(size_t)screenWidth
                        screenHeight:(size_t)screenHeight
                             columns:(GLuint)columnCount
                           direction:(BlindsDirection)direction;
@end
