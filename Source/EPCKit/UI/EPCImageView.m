//
//  EPCImageView.m
//
//  Created by Everton Postay Cunha on 15/05/12.
//

#import "EPCImageView.h"

@interface EPCImageView () {
	UIActivityIndicatorView *actView;
	NSURL *currentURL;
	BOOL imageCacheIsDefault;
	BOOL customActView;
	NSURLConnection *_urlConnection;
	NSMutableData *_receivedData;
}
@end


@implementation EPCImageView

@synthesize imageCache,delegate;

- (void)commonInit {
	self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	self.activityIndicatorViewColor = [UIColor lightGrayColor];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(NSCache *)imageCache {
	if (!imageCache && !_dontCachesImages) {
		imageCacheIsDefault = YES;
		self.imageCache = [[self class] imageCache];
	}
	return imageCache;
}

+(NSCache *)imageCache {
	__strong static id cache = nil;
	if (!cache) {
		cache = [[NSCache alloc] init];
	}
	return cache;
}

- (UIImage *)cachedImageForURL:(NSURL *)url {
	return [self.imageCache objectForKey:[url absoluteString]];
}

- (void)dealloc
{
	self.delegate = nil;
	
	if (!imageCacheIsDefault)
		self.imageCache = nil;
}

- (void)cancel {
	[_urlConnection cancel];
	_urlConnection = nil;
	_receivedData = nil;
}

-(BOOL)retry {
	if (currentURL) {
		[self setImageByURL:[NSURL URLWithString:[currentURL absoluteString]]];
		return YES;
	}
	return NO;
}

- (void)loadImageWithoutURL {
	[self setImageByURL:[NSURL URLWithString:@"http://www.google.com"]];
	self.dontCachesImages = YES;
}

-(void)setImageByURL:(NSURL *)url {
		
	[self cancel];
	
	currentURL = nil;
	
	if (!self.transitionBetweenImages) {
		self.image = nil;
	}
	
	[actView stopAnimating];
	
	if (url) {
		
		currentURL = url;
		
		if (!actView && !self.hideActivityIndicator) {
			actView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:self.activityIndicatorViewStyle];
			actView.hidesWhenStopped = YES;
			actView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
			actView.color = self.activityIndicatorViewColor;
			[self addSubview:actView];
		}
		
		
		if ([self.delegate respondsToSelector:@selector(epcImageView:shouldHandleImageForURL:)]) {
			if (![self.delegate epcImageView:self shouldHandleImageForURL:url]) {
				return;
			}
		}
		
		// run operation
		
		if (!self.image) {
			[actView startAnimating];
		}
		
		[self startRequest];
	}
}

- (NSURL *)imageURL {
	return currentURL;
}

-(void)setActivityIndicatorView:(UIActivityIndicatorView *)activityIndicatorView {
	[actView removeFromSuperview];
	actView = activityIndicatorView;
	
	if (activityIndicatorView) {
		customActView = YES;
	}
	else {
		customActView = NO;
	}
}

- (UIActivityIndicatorView *)activityIndicatorView {
	return actView;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	if (!customActView) {
		actView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
	}
}

- (void)animateTransitionBetweenImages {
	
	if (_transitionBetweenImagesAnimation == NULL) {
		UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.frame];
		imgView.autoresizingMask = self.autoresizingMask;
		imgView.contentMode = self.contentMode;
		imgView.image = self.image;
		imgView.clipsToBounds = self.clipsToBounds;
		[self.superview addSubview:imgView];
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDelegate:imgView];
		[UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDuration:0.333f];
		imgView.alpha = 0.2f;
		[UIView commitAnimations];
	}
	else {
		self.transitionBetweenImagesAnimation(self.image);
	}
}

- (void)gotDownloadedImage:(UIImage*)image url:(NSURL*)url {
	dispatch_sync(dispatch_get_main_queue(), ^{
		if (url == currentURL) {
			[actView stopAnimating];
			
			if (self.transitionBetweenImages && self.image) {
				[self animateTransitionBetweenImages];
			}
			
			self.image = image;
			
			if ([self.delegate respondsToSelector:@selector(epcImageView:isShowingImage:fromURL:isFromCache:)])
				[self.delegate epcImageView:self isShowingImage:self.image fromURL:currentURL isFromCache:NO];
		}
	});
}

- (void)gotImageFromCache:(UIImage*)image url:(NSURL*)url {
	dispatch_sync(dispatch_get_main_queue(), ^{
		if (url == currentURL) {
			[actView stopAnimating];
			
			if (self.transitionBetweenImages && self.image) {
				[self animateTransitionBetweenImages];
			}
			
			self.image = image;
			if ([self.delegate respondsToSelector:@selector(epcImageView:isShowingImage:fromURL:isFromCache:)])
				[self.delegate epcImageView:self isShowingImage:self.image fromURL:currentURL isFromCache:NO];
		}
	});
}


- (void)noImageFromURL:(NSURL*)url {
    assert([NSThread isMainThread]);
    if (url == currentURL) {
        [actView stopAnimating];
		self.image = nil;
        if ([self.delegate respondsToSelector:@selector(epcImageView:failedLoadingURL:)]) {
            [self.delegate epcImageView:self failedLoadingURL:currentURL];
        }
        _receivedData = nil;
        _urlConnection = nil;
    }
}

- (void)requestWillStartWithURL:(NSURL*)url {
	if ([self.delegate respondsToSelector:@selector(epcImageView:willStartRequestForURL:)]) {
		[self.delegate epcImageView:self willStartRequestForURL:url];
	}
}

- (void)requestFinishedForURL:(NSURL*)url {
	if (url == currentURL) {
		if ([self.delegate respondsToSelector:@selector(epcImageView:finishedRequestForURL:)]) {
			[self.delegate epcImageView:self finishedRequestForURL:url];
		}
		_receivedData = nil;
		_urlConnection = nil;
	}
}

- (BOOL)isRequesting {
	return _urlConnection != nil;
}


#pragma MARK - REQUEST

- (void)startRequest {
		
	[_urlConnection cancel];
	_urlConnection = nil;
	_receivedData = nil;
	
	NSURL *url = currentURL;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		
		BOOL imageIsFromCache = YES;
		
		__block UIImage * grabbedImage = [self cachedImageForURL:url];
		
		if (!grabbedImage) {
			// tenta do cache
			
			if ([self.delegate respondsToSelector:@selector(epcImageView:imageForURL:)]) {
				
				grabbedImage = [self.delegate epcImageView:self imageForURL:url];
				
				if (grabbedImage) {
					[self.imageCache setObject:grabbedImage forKey:[url absoluteString]];
				}
			}
		}
		
		if (!grabbedImage) {
			// tenta por url
			imageIsFromCache = NO;
			
			[self performSelectorOnMainThread:@selector(requestWillStartWithURL:) withObject:url waitUntilDone:YES];
			
			NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10];
			
			 dispatch_async(dispatch_get_main_queue(), ^{
				_urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
			 });
		}
		else {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self resolveConnectionResultImageIsFromCache:imageIsFromCache image:grabbedImage];
			});
		}
	});
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	_receivedData = nil;
	[self resolveConnectionResultImageIsFromCache:NO image:nil];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	if (!_receivedData) {
		_receivedData = [NSMutableData data];
	}
	[_receivedData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	if ([self.delegate respondsToSelector:@selector(epcImageView:receivedImageData:fromURL:)]) {
		[self.delegate epcImageView:self receivedImageData:_receivedData fromURL:currentURL];
	}
	
	[self resolveConnectionResultImageIsFromCache:NO image:nil];
}

- (void)resolveConnectionResultImageIsFromCache:(BOOL)imageIsFromCache image:(UIImage*)image {
	
	NSURL *url = currentURL;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		
		UIImage *grabbedImage = image;
		
		if (!grabbedImage && _receivedData) {
			grabbedImage = [UIImage imageWithData:_receivedData];
			_receivedData = nil;
		}
		
		if (grabbedImage) {
			// sucessfull
			
			if (imageIsFromCache) {
				// from cache
				[self gotImageFromCache:grabbedImage url:url]; //sync
			}
			else {
				// downloaded
				[self performSelectorOnMainThread:@selector(requestFinishedForURL:) withObject:url waitUntilDone:YES];
				[self gotDownloadedImage:grabbedImage url:url]; //sync
			}
		}
		else {
			// failed
			[self performSelectorOnMainThread:@selector(noImageFromURL:) withObject:url waitUntilDone:YES];
		}
	});
}
@end
