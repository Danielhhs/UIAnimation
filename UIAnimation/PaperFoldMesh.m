//
//  PaperFoldMesh.m
//  PaperFoldAnimation
//
//  Created by Huang Hongsen on 6/10/15.
//  Copyright (c) 2015 cn.daniel. All rights reserved.
//

#import "PaperFoldMesh.h"
@interface PaperFoldMesh() {
    SceneMeshVertex *vertices;
}
@property (nonatomic) size_t rowCount;
@property (nonatomic) GLfloat yResolution;
@property (nonatomic) GLfloat headerResolution;
@property (nonatomic) size_t headerHeight;
@property (nonatomic) size_t vertexCount;
@property (nonatomic) size_t screenWidth;
@property (nonatomic) size_t screenHeight;
@end

@implementation PaperFoldMesh

- (instancetype) initWithScreenWidth:(size_t)screenWidth
                        screenHeight:(size_t)screenHeight
                            rowCount:(size_t)rowCount
                        headerHeight:(size_t)headerHeight
{
    _headerHeight = headerHeight;
    _headerResolution = (GLfloat)headerHeight / screenHeight;
    _rowCount = rowCount;
    _yResolution = (GLfloat)(screenHeight - headerHeight) / rowCount;
    _screenWidth = screenWidth;
    _screenHeight = screenHeight;
    
    _vertexCount = (rowCount + 1) * 2 * 2;
    GLsizeiptr vertexSize = _vertexCount * sizeof(SceneMeshVertex);
    vertices = malloc(vertexSize);
    
    [self updateWithYPosition:(GLfloat)headerHeight];
    size_t indexCount = (rowCount + 1) * 4;
    GLsizeiptr indexSize = indexCount * sizeof(GLushort);
    GLushort *indices = malloc(indexSize);
    int index = 0;
    for (int i = 0; i < rowCount + 1; i++) {
        indices[index++] = i * 4 + 0;
        indices[index++] = i * 4 + 1;
        indices[index++] = i * 4 + 2;
        indices[index++] = i * 4 + 3;
    }
    NSData *vertexData = [NSData dataWithBytes:vertices length:vertexSize];
    NSData *indicesData = [NSData dataWithBytes:indices length:indexSize];
    return [self initWithVerticesData:vertexData indicesData:indicesData];
}

- (void) drawEntireMesh
{
    for (int i = 0; i < self.rowCount + 1; i++) {
        glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_SHORT, NULL + (i * 4) * sizeof(GLushort));
    }
}

- (void) updateWithYPosition:(GLfloat)yPosition
{
    GLfloat angle = acos((yPosition - self.headerHeight) / (self.screenHeight - self.headerHeight));
    
    //for Header
    vertices[0].position = GLKVector3Make(0, self.screenHeight, 0);
    vertices[0].texCoords = GLKVector2Make(0, 0);
    vertices[1].position = GLKVector3Make(self.screenWidth, self.screenHeight, 0);
    vertices[1].texCoords = GLKVector2Make(1, 0);
    
    vertices[2].position = GLKVector3Make(0, self.screenHeight - self.headerHeight, 0);
    vertices[2].texCoords = GLKVector2Make(0, (GLfloat)self.headerHeight / self.screenHeight);
    vertices[3].position = GLKVector3Make(self.screenWidth, self.screenHeight - self.headerHeight, 0);
    vertices[3].texCoords = GLKVector2Make(1, (GLfloat)self.headerHeight / self.screenHeight);
    
    GLfloat ty = (GLfloat)_yResolution / self.screenHeight;
    for (int i = 1; i < self.rowCount + 1; i++) {
        int index = i * 4;
        vertices[index].position = vertices[index - 2].position;
        vertices[index].texCoords = vertices[index - 2].texCoords;
        
        index++;
        vertices[index].position = vertices[index - 2].position;
        vertices[index].texCoords = vertices[index - 2].texCoords;
        
        index++;
        vertices[index].position.x = 0;
        vertices[index].position.y = vertices[index - 2].position.y - self.yResolution * cos(angle);
        if (i % 2 == 1) {
            vertices[index].position.z = -self.yResolution * sin(angle);;
        } else {
            vertices[index].position.z = 0;
        }
        vertices[index].texCoords.s = 0;
        vertices[index].texCoords.t = vertices[index - 2].texCoords.t + ty;
        
        index++;
        vertices[index].position.x = self.screenWidth;
        vertices[index].position.y = vertices[index - 1].position.y;
        vertices[index].position.z = vertices[index - 1].position.z;
        vertices[index].texCoords.s = 1;
        vertices[index].texCoords.t = vertices[index - 1].texCoords.t;
    }
    [self updateNormals];
    
    
    [self makeDynamicAndUpdateWithVertices:vertices numberOfVertices:self.vertexCount];
}

- (void) updateNormals
{
    vertices[0].normal = GLKVector3Make(0, 0, 1);
    vertices[1].normal = GLKVector3Make(0, 0, 1);
    vertices[2].normal = GLKVector3Make(0, 0, 1);
    vertices[3].normal = GLKVector3Make(0, 0, 1);
    
    for (int i = 1; i < self.rowCount + 1; i++) {
        int index = i * 4;
        GLKVector3 ca = GLKVector3Subtract(vertices[index + 2].position, vertices[index].position);
        GLKVector3 ba = GLKVector3Subtract(vertices[index + 1].position, vertices[index].position);
        vertices[index].normal = GLKVector3CrossProduct(ca, ba);
        index++;
        vertices[index].normal = vertices[index - 1].normal;
        index++;
        vertices[index].normal = vertices[index - 1].normal;
        index++;
        vertices[index].normal = vertices[index - 1].normal;
        
    }
}

@end
