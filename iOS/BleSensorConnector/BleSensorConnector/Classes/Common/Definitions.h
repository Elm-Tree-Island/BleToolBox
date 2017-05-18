//
//  Definitions.h
//  BleSensorConnector
//
//  Created by Mark C.J. on 18/05/2017.
//  Copyright © 2017 MarkCJ. All rights reserved.
//

#ifndef Definitions_h
#define Definitions_h

// 单例声明宏
#define instance_interface(className, instanceMethod)   \
\
+ (instancetype)instanceMethod;

// 单例实现方法宏
#define instance_implementation(className, instanceMethod)   \
\
static className * _instance; \
\
+ (instancetype)instanceMethod \
{   static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [[self alloc] init]; \
}); \
return _instance; \
} \
\
+ (id)allocWithZone:(struct _NSZone *)zone { \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
} \
\
- (id)copyWithZone:(NSZone *)zone { \
return _instance; \
}



#endif /* Definitions_h */
