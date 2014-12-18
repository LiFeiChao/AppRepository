// AFAppDotNetAPIClient.h
//
// Copyright (c) 2012 Mattt Thompson (http://mattt.me/)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFIntelligentCommunityClient.h"

#import "AFJSONRequestOperation.h"

//static NSString * const kAFIntelligentCommunityBaseURLString = @"http://180.168.123.158:8412/tjpt/api/";
//static NSString * const kAFIntelligentCommunityBaseURLString = @"http://180.168.123.218:8010/tjpt/api/";

//static NSString * const kAFIntelligentCommunityBaseURLString = @"http://127.0.0.1:8080/tjpt/api/";
//static NSString * const kAFIntelligentCommunityBaseURLString = @"http://172.31.21.130/tjpt/api/";
static NSString * const kAFIntelligentCommunityBaseURLString = @"http://202.55.17.7/tjpt/api/";

@implementation AFIntelligentCommunityClient

+ (AFIntelligentCommunityClient *)sharedClient {
    static AFIntelligentCommunityClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    _sharedClient = [[AFIntelligentCommunityClient alloc] initWithBaseURL:[NSURL URLWithString:kAFIntelligentCommunityBaseURLString]];
        
    });
//     AF/Users/Ideal/Work/Project/IOS/IOSIntelligentCommunity/IntelligentCommunity/DocumentInfo.hIntelligentCommunityClient *_sharedClient = [[AFIntelligentCommunityClient alloc] initWithBaseURL:[NSURL URLWithString:kAFIntelligentCommunityBaseURLString]];
    return _sharedClient;
    
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    //[self setDefaultHeader:@"Content-Type" value:@"application/json"];
    self.parameterEncoding=AFJSONParameterEncoding;
    return self;
}

@end
