//
//  SceneMesh.h
//  StartAgain
//
//  Created by Huang Hongsen on 5/18/15.
//  Copyright (c) 2015 com.microstrategy. All rights reserved.
//

#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector2 texCoords;
}SceneMeshVertex;

@interface SceneMesh : NSObject

- (instancetype) initWithVerticesData:(NSData *)verticesData indicesData:(NSData *)indicesData;
- (void) prepareToDraw;
- (void) drawIndicesWithMode:(GLenum)mode startIndex:(GLuint)index indicesCount:(size_t)indicesCount;
- (void) makeDynamicAndUpdateWithVertices:(const SceneMeshVertex *)vertices numberOfVertices:(size_t)numberOfVertices;
- (void) tearDown;
@end
