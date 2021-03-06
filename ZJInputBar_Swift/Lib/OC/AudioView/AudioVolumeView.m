//
//  AudioVolumeView.m
//  Coding_iOS
//
//  Created by sumeng on 8/2/15.
//  Copyright (c) 2015 Coding. All rights reserved.
//

#import "AudioVolumeView.h"
#import "UIColor+expanded.h"

@interface AudioVolumeView ()

@property (nonatomic, strong) NSMutableArray *volumeViews;
@property (nonatomic, strong) NSMutableArray *volumes;

@end

@implementation AudioVolumeView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initStyle];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initStyle];
    }
    return self;
}

-(void)initStyle{
    _volumes = [[NSMutableArray alloc] initWithCapacity:kAudioVolumeViewVolumeNumber];
    _volumeViews = [[NSMutableArray alloc] initWithCapacity:kAudioVolumeViewVolumeNumber];
    for (int i = 0; i < kAudioVolumeViewVolumeNumber; i++) {
        [_volumes addObject:@0];
        
        UIView *volumeView = [[UIView alloc] initWithFrame:CGRectMake((kAudioVolumeViewVolumeWidth+kAudioVolumeViewVolumePadding)*i, (self.frame.size.height-kAudioVolumeViewVolumeMinHeight)/2, kAudioVolumeViewVolumeWidth, kAudioVolumeViewVolumeMinHeight)];
        volumeView.backgroundColor = [UIColor colorWithRGBHex:0xfb8638];
        volumeView.layer.cornerRadius = volumeView.frame.size.width/2;
        [self addSubview:volumeView];
        [_volumeViews addObject:volumeView];
    }
    
    self.type = AudioVolumeViewTypeLeft;
}

- (void)addVolume:(double)volume {
    if (_type == AudioVolumeViewTypeRight) {
        [_volumes removeLastObject];
        [_volumes insertObject:[NSNumber numberWithDouble:volume] atIndex:0];
    }
    else {
        [_volumes removeObjectAtIndex:0];
        [_volumes addObject:[NSNumber numberWithDouble:volume]];
    }
    [self layoutVolumes];
}

- (void)clearVolume {
    [_volumes removeAllObjects];
    for (int i = 0; i < _volumeViews.count; i++) {
        [_volumes addObject:@0];
    }
    [self layoutVolumes];
}

- (void)layoutVolumes {
    for (int i = 0; i < _volumeViews.count; i++) {
        UIView *volumeView = _volumeViews[i];
        NSNumber *volume = _volumes[i];
        CGRect frame = volumeView.frame;
        frame.size.height = [self heightOfVolume:volume.doubleValue];
        volumeView.frame = frame;
        volumeView.center = CGPointMake(volumeView.center.x, self.frame.size.height/2);
    }
}

- (CGFloat)heightOfVolume:(double)volume {
    CGFloat height = kAudioVolumeViewVolumeMinHeight + (kAudioVolumeViewVolumeMaxHeight - kAudioVolumeViewVolumeMinHeight) * volume;
    return height;
}

@end
