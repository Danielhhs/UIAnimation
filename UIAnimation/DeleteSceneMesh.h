//
//  DeleteSceneMesh.h
//  StartAgain
//
//  Created by Huang Hongsen on 5/18/15.
//  Copyright (c) 2015 com.microstrategy. All rights reserved.
//

#import "SceneMesh.h"

@interface DeleteSceneMesh : SceneMesh
- (instancetype) initWithTargetView:(UIView *)view;
- (void) drawEntireMesh;
@end
