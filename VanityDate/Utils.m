//
//  Utils.m
//  HashCat
//
//  Created by iOSDevStar on 6/18/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "Utils.h"
#import "Global.h"

@implementation Utils

-(id) init
{
    if((self = [super init]))
    {
    }
    return self;
}

+ (Utils *)sharedObject
{
    static Utils *objUtility = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objUtility = [[Utils alloc] init];
    });
    return objUtility;
}

- (CGFloat) getHeightOfText:(NSString *)strText fontSize:(float) fFontSize width:(float) fWidth
{
    CGFloat height = 0.0;
    CGFloat commentlabelWidth = fWidth - 5.f;
    CGRect rect = [strText boundingRectWithSize:(CGSize){commentlabelWidth, MAXFLOAT}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:[UIFont fontWithName:MAIN_FONT_NAME size:fFontSize]}
                                        context:nil];
    height = rect.size.height;
    return height;
}

-(NSString *)DateToString:(NSDate *)date withFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];//2013-07-15:10:00:00
    NSString * strdate = [formatter stringFromDate:date];
    return strdate;
}

- (NSDate *) StringToDate:(NSString *) strDate withFormat:(NSString *)format;
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];//2013-07-15:10:00:00
    NSDate* date = [formatter dateFromString:strDate];
    
    return date;
}

- (NSString *) timeInMiliSeconds:(NSDate *) date
{
    NSString * timeInMS = [NSString stringWithFormat:@"%lld", [@(floor([date timeIntervalSince1970] * 1000)) longLongValue]];
    return timeInMS;
}

- (NSDate *) getDateFromMilliSec:(long long) lMilliSeconds
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(lMilliSeconds)];
    
    return date;
}

- (bool) checkAvailableBirth:(NSString *)strSelectedBirth
{
    int nMyYear = (int)[[strSelectedBirth substringToIndex:4] integerValue];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDate *currDate = [NSDate date];
    NSDateComponents *dComp = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit )
                                          fromDate:currDate];
    
    int year = (int)[dComp year];
    int nMyAge = year - nMyYear;
    if (nMyAge < 18)
    {
        return false;
    }
    else
        return true;

}

- (NSString *)urlEncodeWithString: (NSString*)string
{
    CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(
                                                                    NULL,
                                                                    (CFStringRef)string,
                                                                    NULL,
                                                                    (CFStringRef)@"!*'\"();+$,%#[]% ",
                                                                    kCFStringEncodingUTF8 );
    return (NSString *)CFBridgingRelease(urlString);
}

- (NSString *) makeAPIURLString:(NSString *)strActionName
{
    NSString* strUrl = [NSString stringWithFormat:@"%@%@", SERVER_URL, strActionName];
    return  strUrl;
}

- (NSString *) makeResourceURLString:(NSString *)strResourceName
{
    NSString* strUrl = [NSString stringWithFormat:@"%@%@", RESOURCE_URL, strResourceName];
    return  strUrl;
}

- (void) saveImageToLocal:(UIImage *)image withName:(NSString *) strName
{
    NSData *pngData = UIImageJPEGRepresentation(image, 0.6);
    
    NSString *filePath = [DOCUMENTS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", strName]];
    [pngData writeToFile:filePath atomically:YES]; //Write the file
    
    pngData  = nil;
}

- (UIImage *) readImageFromLocal:(NSString *) strName
{
    UIImage* image = nil;
    NSString *filePath = [DOCUMENTS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", strName]];
    NSData *imgData = [NSData dataWithContentsOfFile:filePath];
    if (imgData)
        image = [[UIImage alloc] initWithData:imgData];
    imgData = nil;
    
    return  image;
}

- (NSString *) getImageNameFromLink:(NSString *) strResourceLink
{
    NSString* strFileName = @"";
    NSArray* arrayStrings = [strResourceLink componentsSeparatedByString:@"/"];
    if (arrayStrings.count == 0)
        strFileName = @"nophoto";
    else
        strFileName = [arrayStrings lastObject];
    
    return strFileName;
}

-(UIImage *)rn_boxblurImageWithBlur:(CGFloat)blur exclusionPath:(UIBezierPath *)exclusionPath image:(UIImage *)processImage
{
    if (!processImage)
        return nil;
    
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = processImage.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    // create unchanged copy of the area inside the exclusionPath
    UIImage *unblurredImage = nil;
    //create vImage_Buffer with data from CGImageRef
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    // Create a third buffer for intermediate processing
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo) kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    // overlay images?
    if (unblurredImage != nil) {
        UIGraphicsBeginImageContext(returnImage.size);
        [returnImage drawAtPoint:CGPointZero];
        [unblurredImage drawAtPoint:CGPointZero];
        
        returnImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    CGImageRelease(imageRef);
    
    return returnImage;
}

-(BOOL)validateEmail:(NSString*)email
{
    if( (0 != [email rangeOfString:@"@"].length) &&  (0 != [email rangeOfString:@"."].length) )
    {
        NSMutableCharacterSet *invalidCharSet = [[[NSCharacterSet alphanumericCharacterSet] invertedSet]mutableCopy];
        [invalidCharSet removeCharactersInString:@"_-"];
        
        NSRange range1 = [email rangeOfString:@"@" options:NSCaseInsensitiveSearch];
        
        // If username part contains any character other than "."  "_" "-"
        NSString *usernamePart = [email substringToIndex:range1.location];
        NSArray *stringsArray1 = [usernamePart componentsSeparatedByString:@"."];
        for (NSString *string in stringsArray1)
        {
            NSRange rangeOfInavlidChars=[string rangeOfCharacterFromSet: invalidCharSet];
            if(rangeOfInavlidChars.length !=0 || [string isEqualToString:@""])
                return NO;
        }
        
        NSString *domainPart = [email substringFromIndex:range1.location+1];
        NSArray *stringsArray2 = [domainPart componentsSeparatedByString:@"."];
        
        for (NSString *string in stringsArray2)
        {
            NSRange rangeOfInavlidChars=[string rangeOfCharacterFromSet:invalidCharSet];
            if(rangeOfInavlidChars.length !=0 || [string isEqualToString:@""])
                return NO;
        }
        
        return YES;
    }
    else
        return NO;
}


-(UIImage *)makeRoundedImage:(UIImage *) image radius: (float) radius
{
    CALayer *imageLayer = [CALayer layer];
    NSLog(@"size =%f, %f", image.size.width, image.size.height);
    
    float fFinalSize = image.size.width;
    if (image.size.width > image.size.height)
        fFinalSize = image.size.height;
    
    imageLayer.frame = CGRectMake(0, 0, fFinalSize, fFinalSize);
    imageLayer.contents = (id) image.CGImage;
    
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = fFinalSize / 2.f;
    
    UIGraphicsBeginImageContext(CGSizeMake(fFinalSize, fFinalSize));
    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return roundedImage;
}

- (void) makeBlurImage:(NSString *) strPhoto imageView:(UIImageView *)imageViewTaget;
{
    imageViewTaget.image = [self rn_boxblurImageWithBlur:0.2f exclusionPath:nil image:[UIImage imageNamed:@"upload_bg.png"]];
    
    if ([strPhoto isKindOfClass:[NSNull class]]) return;
    if (strPhoto == nil || [strPhoto isEqualToString:@""]) return;
    
    float fRadius = 0.f;
    if (imageViewTaget.frame.size.width > imageViewTaget.frame.size.height)
        fRadius = imageViewTaget.frame.size.height / 2.f;
    else
        fRadius = imageViewTaget.frame.size.width / 2.f;
    
    NSString* strFileName = [self getImageNameFromLink:strPhoto];
    UIImage *image = [self readImageFromLocal:strFileName];
    if (image)
    {
        imageViewTaget.image = [self rn_boxblurImageWithBlur:0.6f exclusionPath:nil image:image];
    }
    else
    {
        __block UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityView.center = CGPointMake(imageViewTaget.frame.size.width / 2, imageViewTaget.frame.size.height / 2);
        activityView.color = MAIN_COLOR;
        [imageViewTaget addSubview:activityView];
        [activityView startAnimating];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
            NSURL* urlWithString = [NSURL URLWithString:strPhoto];
            __block NSData* imageData = [NSData dataWithContentsOfURL:urlWithString];
            dispatch_async(dispatch_get_main_queue(), ^{ // 2
                UIImage* downloadedImage = [UIImage imageWithData:imageData];
                [[Utils sharedObject] saveImageToLocal:downloadedImage withName:strFileName];
                imageViewTaget.image = [self rn_boxblurImageWithBlur:0.6f exclusionPath:nil image:downloadedImage];
                
                [activityView stopAnimating];
                activityView.hidden = YES;
                [activityView removeFromSuperview];
                activityView = nil;
                
                imageData = nil;
                downloadedImage = nil;
            });
        });
    }
}

- (void) loadImageFromServerAndLocal:(NSString *) strPhoto imageView:(UIImageView *)imageViewTaget
{
    if ([strPhoto isKindOfClass:[NSNull class]]) return;
    if (strPhoto == nil || [strPhoto isEqualToString:@""]) return;
    
    float fRadius = 0.f;
    if (imageViewTaget.frame.size.width > imageViewTaget.frame.size.height)
        fRadius = imageViewTaget.frame.size.height / 2.f;
    else
        fRadius = imageViewTaget.frame.size.width / 2.f;
    
    NSString* strFileName = [self getImageNameFromLink:strPhoto];
    UIImage *image = [self readImageFromLocal:strFileName];
    if (image)
    {
        imageViewTaget.image = [self makeRoundedImage:image radius:fRadius];
    }
    else
    {
        __block UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityView.center = CGPointMake(imageViewTaget.frame.size.width / 2, imageViewTaget.frame.size.height / 2);
        activityView.color = MAIN_COLOR;
        [imageViewTaget addSubview:activityView];
        [activityView startAnimating];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
            NSURL* urlWithString = [NSURL URLWithString:strPhoto];
            __block NSData* imageData = [NSData dataWithContentsOfURL:urlWithString];
            dispatch_async(dispatch_get_main_queue(), ^{ // 2
                UIImage* downloadedImage = [UIImage imageWithData:imageData];
                [[Utils sharedObject] saveImageToLocal:downloadedImage withName:strFileName];
                imageViewTaget.image = [[Utils sharedObject] makeRoundedImage:downloadedImage radius:fRadius];
                
                [activityView stopAnimating];
                activityView.hidden = YES;
                [activityView removeFromSuperview];
                activityView = nil;
                
                imageData = nil;
                downloadedImage = nil;
            });
        });
    }
}

- (void) loadImageFromServerAndLocalWithoutRound:(NSString *) strPhoto imageView:(UIImageView *)imageViewTaget
{
    if ([strPhoto isKindOfClass:[NSNull class]]) return;
    if (strPhoto == nil || [strPhoto isEqualToString:@""]) return;
    
    float fRadius = 0.f;
    if (imageViewTaget.frame.size.width > imageViewTaget.frame.size.height)
        fRadius = imageViewTaget.frame.size.height / 2.f;
    else
        fRadius = imageViewTaget.frame.size.width / 2.f;
    
    NSString* strFileName = [self getImageNameFromLink:strPhoto];
    UIImage *image = [self readImageFromLocal:strFileName];
    if (image)
    {
        imageViewTaget.image = image;
    }
    else
    {
        __block UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityView.center = CGPointMake(imageViewTaget.frame.size.width / 2, imageViewTaget.frame.size.height / 2);
        activityView.color = MAIN_COLOR;
        [imageViewTaget addSubview:activityView];
        [activityView startAnimating];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
            NSURL* urlWithString = [NSURL URLWithString:strPhoto];
            __block NSData* imageData = [NSData dataWithContentsOfURL:urlWithString];
            dispatch_async(dispatch_get_main_queue(), ^{ // 2
                UIImage* downloadedImage = [UIImage imageWithData:imageData];
                imageViewTaget.image = downloadedImage;
                
                [[Utils sharedObject] saveImageToLocal:downloadedImage withName:strFileName];
                
                [activityView stopAnimating];
                activityView.hidden = YES;
                [activityView removeFromSuperview];
                activityView = nil;
                
                imageData = nil;
                downloadedImage = nil;
            });
        });
    }
}

- (int) readEventSetting:(NSString *) strField
{
    int nVal = (int)[[NSUserDefaults standardUserDefaults] integerForKey:strField];
    if (nVal == 0 && [strField isEqualToString:@"around"])
    {
        nVal = 1;
        [self saveEventSetting:strField value:nVal];
    }
    
    return nVal;
}

- (void) saveEventSetting:(NSString *) strField value:(int) nValue
{
    [[NSUserDefaults standardUserDefaults] setInteger:nValue forKey:strField];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *) readEventSettingContent:(NSString *) strField
{
    NSString* strContent = [[NSUserDefaults standardUserDefaults] valueForKey:strField];
    if (!strContent && [strField isEqualToString:@"around_content"])
    {
        strContent = @"3 miles";
        [self saveEventSettingContent:strField value:strContent];
    }
    
    return strContent;
}

- (void) saveEventSettingContent:(NSString *) strField value:(NSString *) strContent;
{
    [[NSUserDefaults standardUserDefaults] setValue:strContent forKey:strField];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *) checkAvaiablityForNumber:(id) pObj
{
    if ([pObj isKindOfClass:[NSNull class]])
        return @"0";
    else
        return pObj;
}

- (NSString *) checkAvaiablityForString:(id) pObj
{
    if ([pObj isKindOfClass:[NSNull class]])
        return @"";
    else
        return pObj;
}

@end
