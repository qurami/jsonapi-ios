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
    
    [client getJSONAPIDocumentWithPath:@"organizations/x" includedResourceTypes: resourcesToInclude completionHandler:^(JSONAPIDocument *jsonApi, NSInteger statusCode, NSError *error) {
        
        
        if(!error){
        
            JSONAPIResource *quramiResource;
            NSArray *allResources = (NSArray *) jsonApi.data;
            for (JSONAPIResource *thisResource in allResources) {
                if([thisResource.ID isEqualToString:@"1"]){
                    quramiResource = thisResource;
                    break;
                }
            }
            
            NSArray *quramiOffices = [jsonApi includedResourcesForJSONAPIResource: quramiResource];
            NSLog(@"resource %@ has %ld included resources", quramiResource.attributes[@"name"], [quramiOffices count]);
            
        }
        else{
            
            NSLog(@"error returned: %@", error.localizedDescription);
        
        }
    }];
    
}

@end
