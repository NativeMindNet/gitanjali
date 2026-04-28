//
//  BToolFunctions.m
//  books
//
//  Created by Dmitry Panin on 26.01.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "BToolFunctions.h"
#import <AudioToolbox/AudioToolbox.h>
#import "id3/tag.h"
#import "id3/misc_support.h"

NSString* pathOfResourceWithTemplate(NSString *templ)
{
	NSString* res = [NSString stringWithString: templ];
	res = [res stringByReplacingOccurrencesOfString: @"($APP_BUNDLE)" withString: [[NSBundle mainBundle] bundlePath]];
	res = [res stringByReplacingOccurrencesOfString: @"($TEMP_DIR)" withString: NSTemporaryDirectory()];
	NSString* docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
	res = [res stringByReplacingOccurrencesOfString: @"($DOCS_DIR)" withString: docDir];	
	
	return res;
}

NSString* extractNameFromSoundFile(NSURL* file)
{
	NSString* path = [file path];
	
	if(![[path pathExtension] isEqualToString: @"mp3"])
	{
		NSString* filename = [[path lastPathComponent] stringByDeletingPathExtension];
		
		return filename;
	}
	
	AudioFileID fileID  = nil;
    OSStatus err        = noErr;
    
    err = AudioFileOpenURL( (CFURLRef) file, kAudioFileReadPermission, 0, &fileID );
 
	if( err != noErr ) 
	{
		return nil;
    }
	
	UInt32 id3DataSize  = 0;
    char * rawID3Tag    = NULL;
	
    err = AudioFileGetPropertyInfo( fileID, kAudioFilePropertyID3Tag, &id3DataSize, NULL );
    
	if( err != noErr ) 
	{
		return nil;
    }
	
    rawID3Tag = (char *) malloc( id3DataSize );
    
	if( rawID3Tag == NULL ) 
	{
		return nil;
    }
    
    err = AudioFileGetProperty( fileID, kAudioFilePropertyID3Tag, &id3DataSize, rawID3Tag );
	
    if( err != noErr ) 
	{
		return nil;
    }
	
	ID3_Tag tag;
	tag.Parse((const uchar*)rawID3Tag, id3DataSize);
	
	NSString* res = nil;
	
	ID3_Frame* frame = tag.Find(ID3FID_TITLE);
	
	if(frame)
	{
		char* str = ID3_GetString(frame, ID3FN_TEXT);
		
		if(str)
		{
			res = [NSString stringWithUTF8String: str];
			ID3_FreeString(str);
		}
	}
	
	free(rawID3Tag);
	
	AudioFileClose(fileID);
	
	return res;
}