#import "MicAudioPlugin.h"
#import <mic_audio/mic_audio-Swift.h>

@implementation MicAudioPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMicAudioPlugin registerWithRegistrar:registrar];
}
@end
