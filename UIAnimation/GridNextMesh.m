//
//  GridNextMesh.m
//  GridAnimation
//
//  Created by Huang Hongsen on 6/24/15.
//  Copyright (c) 2015 cn.daniel. All rights reserved.
//

#import "GridNextMesh.h"

@interface GridNextMesh () {
    SceneMeshVertex *verticies;
}

@end

@implementation GridNextMesh

- (instancetype) initWithScreenWidth:(size_t)screenWidth screenHeight:(size_t)screenHeight
{
    verticies = malloc(sizeof(SceneMeshVertex) * 4);
    verticies[0].position = GLKVector3Make(screenWidth + 100, 0, 0);
    verticies[0].texCoords = GLKVector2Make(0, 1);
    verticies[1].position = GLKVector3Make(screenWidth * 2 + 100, 0, 0);
    verticies[1].texCoords = GLKVector2Make(1, 1);
    verticies[2].position = GLKVector3Make(screenWidth + 100, screenHeight, 0);
    verticies[2].texCoords = GLKVector2Make(0, 0);
    verticies[3].position = GLKVector3Make(screenWidth * 2 + 100, screenHeight, 0);
    verticies[3].texCoords = GLKVector2Make(1, 0);
    
    GLushort indicies[4] = {0, 1, 2, 3};
    NSData *vertexData = [NSData dataWithBytes:verticies length:4 * sizeof(SceneMeshVertex)];
    NSData *indexData = [NSData dataWithBytes:indicies length:4 * sizeof(GLushort)];
    return [self initWithVerticesData:vertexData indicesData:indexData];
}

- (void) drawEntireMesh
{
    glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_SHORT, NULL);
}

@end
