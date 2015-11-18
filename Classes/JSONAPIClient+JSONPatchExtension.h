//
//  JSONAPIClient+JSONPatchExtension.h
//  JSONAPI
//
//  Created by Marco Musella on 17/11/15.
//  Copyright © 2015 Josh Holtz. All rights reserved.
//

#import "JSONAPIClient.h"

@class JSONPatchDocument;

@interface JSONAPIClient (JSONPatchExtension)

- (void) patchWithJsonPatchDocumentArray: (NSArray<JSONPatchDocument *> *) array forResourceAtPath: (NSString *) resourcePath completionHandler: (void(^)(NSArray<JSONAPIDocument *> *documents,NSInteger statusCode, NSError *error)) completionHandler;

@end
