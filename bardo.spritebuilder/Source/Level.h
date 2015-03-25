//
//  Level.h
//  GameArchitecture
//
//  Created by Yahya on 10/02/15.
//  Copyright (c) 2014 Apportable. All rights reserved.//

#import "CCNode.h"

@interface Level : CCNode

@property (nonatomic, copy) NSString *nextLevelName;
@property (nonatomic, assign) int levelSpeed;

@end
