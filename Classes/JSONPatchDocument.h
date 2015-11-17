//
//  JSONPatchDocument.h
//  JSONAPI
//
//  Created by Marco Musella on 17/11/15.
//  Copyright © 2015 Josh Holtz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum JSONPatchOperation{
    
    JSONPatchOperationAdd = 0,
    JSONPatchOperationRemove,
    JSONPatchOperationReplace,
    JSONPatchOperationMove,
    JSONPatchOperationCopy,
    JSONPatchOperationTest

}JSONPatchOperation;

@interface JSONPatchDocument : NSObject

@property (nonatomic, assign) JSONPatchOperation op;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) id value;

- (NSString *) convertToJsonStringWithError: (NSError **) error;
- (NSData *) convertToJsonDataWithError: (NSError **) error;

@end
