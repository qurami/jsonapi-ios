//
//  JSONAPIJSONEncoder.h
//  JSONAPI
//
//  Created by Marco Musella on 05/08/15.
//  Copyright (c) 2015 Josh Holtz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSONAPIDocument, JSONAPIResource, JSONAPIError;

@interface JSONAPIJSONEncoder : NSObject

+ (NSString *) jsonEncodedStringForJSONAPIDocument: (JSONAPIDocument *) document;
+ (NSString *) jsonEncodedStringForJSONAPIResource: (JSONAPIResource *) resource;
+ (NSString *) jsonEncodedStringForJSONAPIError: (JSONAPIError *) jsonapiError;

@end
