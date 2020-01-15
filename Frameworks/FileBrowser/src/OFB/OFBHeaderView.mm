#import "OFBHeaderView.h"
#import <OakAppKit/OakAppKit.h>
#import <OakAppKit/OakUIConstructionFunctions.h>

static NSButton* OakCreateImageButton (NSString* imageName)
{
	NSButton* res = [[NSButton alloc] initWithFrame:NSZeroRect];
	[res setButtonType:NSButtonTypeMomentaryChange];
	[res setBordered:NO];
	[res setImage:[NSImage imageNamed:imageName]];
	[res setImagePosition:NSImageOnly];
	[res setContentTintColor: [NSColor secondaryLabelColor]];
	return res;
}

static NSPopUpButton* OakCreateFolderPopUpButton ()
{
	NSPopUpButton* res = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:YES];
	[res setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationHorizontal];
	[res setContentHuggingPriority:NSLayoutPriorityFittingSizeCompression forOrientation:NSLayoutConstraintOrientationHorizontal];
	[res setContentHuggingPriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationVertical];
	[res setBordered:NO];
	[res setContentTintColor: [NSColor secondaryLabelColor]];
	return res;
}

@interface OFBHeaderView ()
@property (nonatomic) NSView* bottomDivider;
@end

@implementation OFBHeaderView
- (id)initWithFrame:(NSRect)aRect
{
	if(self = [super initWithFrame:aRect])
	{
		self.material = NSVisualEffectMaterialWindowBackground;
		self.blendingMode = NSVisualEffectBlendingModeWithinWindow;
		self.state        = NSVisualEffectStateFollowsWindowActiveState;
		
		self.folderPopUpButton       = OakCreateFolderPopUpButton();
		self.goBackButton            = OakCreateImageButton(NSImageNameGoLeftTemplate);
		self.goBackButton.toolTip    = @"Go Back";
		self.goForwardButton         = OakCreateImageButton(NSImageNameGoRightTemplate);
		self.goForwardButton.toolTip = @"Go Forward";

		self.folderPopUpButton.accessibilityLabel           = @"Current folder";
		self.goBackButton.image.accessibilityDescription    = self.goBackButton.toolTip;
		self.goForwardButton.image.accessibilityDescription = self.goForwardButton.toolTip;

		_bottomDivider = OakCreateHorizontalLine(OakBackgroundFillViewStyleDivider);

		NSDictionary* views = @{
			@"folder":        self.folderPopUpButton,
			@"divider":       OakCreateDividerImageView(),
			@"back":          self.goBackButton,
			@"forward":       self.goForwardButton,
			@"bottomDivider": _bottomDivider,
		};

		OakAddAutoLayoutViewsToSuperview([views allValues], self);
		OakSetupKeyViewLoop(@[ self, _folderPopUpButton, _goBackButton, _goForwardButton ], NO);

		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(-3)-[folder(>=75)]-(3)-[divider]-(2)-[back(==22)]-(2)-[forward(==back)]-(3)-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomDivider]|"                                                                options:0 metrics:nil views:views]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[divider][bottomDivider]|"                                                  options:0 metrics:nil views:views]];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidChangeKeyStatus:) name:NSWindowDidResignKeyNotification object:self.window];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidChangeKeyStatus:) name:NSWindowDidBecomeKeyNotification object:self.window];
	}
	return self;
}

- (void)windowDidChangeKeyStatus:(NSNotification *)aNotification {
	BOOL isActive = self.window.isKeyWindow;
	for(NSView* view in self.subviews) {
		 view.alphaValue = isActive ? 1.0 : 0.5;
	}
}

- (NSSize)intrinsicContentSize
{
	return NSMakeSize(NSViewNoIntrinsicMetric, 24);
}
@end
