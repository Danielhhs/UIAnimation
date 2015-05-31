//
//  DeleteSceneMesh.m
//  StartAgain
//
//  Created by Huang Hongsen on 5/18/15.
//  Copyright (c) 2015 com.microstrategy. All rights reserved.
//

#import "DeleteSceneMesh.h"

@implementation DeleteSceneMesh

static GLushort indices[] = {
    0,1,2,
    2,1,3
};

- (instancetype) initWithTargetView:(UIView *)view
{
    
//     SceneMeshVertex vertices[] = {
//        {{-160, -284, 0}, {0, 0, 0},{0, 1}},
//        {{160, -284, 0}, {0, 0, 0},{1, 1}},
//        {{-160, 284, 0}, {0, 0, 0},{0, 0}},
//        {{160, 284, 0}, {0, 0, 0},{1, 0}},
//    };
    SceneMeshVertex vertices[] = {
        {{-view.frame.size.width / 2, -view.frame.size.height / 2, 0}, {0, 0, 0},{0, 1}},
        {{view.frame.size.width / 2, -view.frame.size.height / 2, 0}, {0, 0, 0},{1, 1}},
        {{-view.frame.size.width / 2, view.frame.size.height / 2, 0}, {0, 0, 0},{0, 0}},
        {{view.frame.size.width / 2, view.frame.size.height / 2, 0}, {0, 0, 0},{1, 0}},
    };

    NSData *verticesData = [NSData dataWithBytes:vertices length:sizeof(vertices)];
    NSData *indicesData = [NSData dataWithBytes:indices length:sizeof(indices)];
    return [self initWithVerticesData:verticesData indicesData:indicesData];
}

- (void) drawEntireMesh
{
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_SHORT, NULL);
}

@end
