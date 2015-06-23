//
//  PaperFoldMesh.h
//  PaperFoldAnimation
//
//  Created by Huang Hongsen on 6/10/15.
//  Copyright (c) 2015 cn.daniel. All rights reserved.
//

#import "SceneMesh.h"

@interface PaperFoldMesh : SceneMesh

- (void) updateWithYPosition:(GLfloat)yPosition;

- (instancetype) initWithScreenWidth:(size_t)screenWidth
                        screenHeight:(size_t)screenHeight
                            rowCount:(size_t)rowCount
                        headerHeight:(size_t)headerHeight;

@end
