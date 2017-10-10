//
//  Utils.h
//  HashCat
//
//  Created by iOSDevStar on 6/18/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utils : NSObject

-(id) init;
+ (Utils *)sharedObject;

- (CGFloat) getHeightOfText:(NSString *)strText fontSize:(float) fFontSize width:(float) fWidth;

- (NSString *)urlEncodeWithString: (NSString*)string;

- (NSString *)DateToString:(NSDate *)date withFormat:(NSString *)format;
- (NSDate *) StringToDate:(NSString *) strDate withFormat:(NSString *)format;
- (NSString *) timeInMiliSeconds:(NSDate *) date;
- (NSDate *) getDateFromMilliSec:(long long) lMilliSeconds;

- (NSString *) makeAPIURLString:(NSString *)strActionName;
- (NSString *) makeResourceURLString:(NSString *)strResourceName;

- (void) saveImageToLocal:(UIImage *)image withName:(NSString *) strName;
- (UIImage *) readImageFromLocal:(NSString *) strName;

- (NSString *) getImageNameFromLink:(NSString *) strResourceLink;

-(UIImage *)rn_boxblurImageWithBlur:(CGFloat)blur exclusionPath:(UIBezierPath *)exclusionPath image:(UIImage *)processImage;

-(BOOL)validateEmail:(NSString*)email;

-(UIImage *)makeRoundedImage:(UIImage *) image radius: (float) radius;

- (void) loadImageFromServerAndLocal:(NSString *) strPhoto imageView:(UIImageView *)imageViewTaget;
- (void) loadImageFromServerAndLocalWithoutRound:(NSString *) strPhoto imageView:(UIImageView *)imageViewTaget;

- (void) makeBlurImage:(NSString *) strPhoto imageView:(UIImageView *)imageViewTaget;

- (int) readEventSetting:(NSString *) strField;
- (void) saveEventSetting:(NSString *) strField value:(int) nValue;

- (NSString *) readEventSettingContent:(NSString *) strField;
- (void) saveEventSettingContent:(NSString *) strField value:(NSString *) strContent;

- (NSString *) checkAvaiablityForNumber:(id) pObj;
- (NSString *) checkAvaiablityForString:(id) pObj;

- (bool) checkAvailableBirth:(NSString *) strSelectedBirth;

@end
