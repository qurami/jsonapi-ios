//
//  ViewController.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/23/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "ViewController.h"

#import "JSONAPI.h"

#import "CommentResource.h"
#import "PeopleResource.h"
#import "PostResource.h"

@interface ViewController (){

}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    JSONAPIClient *client = [JSONAPIClient new];
    client.endpoint = @"http://beta.organizations.bdms.qurami.net";
    
    NSArray *resourcesToInclude = @[@"offices"];
    
    [client getJSONAPIDocumentWithPath:@"/app/organizations" includedResourceTypes: resourcesToInclude completionHandler:^(JSONAPIDocument *jsonApi, NSInteger statusCode, NSError *error) {
        
        
        if(!error){
            
            JSONAPIResource *quramiResource;
            if(jsonApi.data){
                NSArray *allResources = (NSArray *) jsonApi.data;
                for (JSONAPIResource *thisResource in allResources) {
                    if([thisResource.ID isEqualToString:@"1"]){
                        quramiResource = thisResource;
                        break;
                    }
                }
                
                
                NSArray *quramiOffices = [quramiResource getRelatedResourcesFromJSONAPIResourcesArray: jsonApi.included];
                NSLog(@"resource %@ has %ld included resources", quramiResource.attributes[@"name"], [quramiOffices count]);
            }
            
        }
        else{
            
            NSLog(@"error returned: %@", error.localizedDescription);
        
        }
    }];
    
}

@end
