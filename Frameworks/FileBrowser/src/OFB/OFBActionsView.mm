#import "OFBActionsView.h"
#import <OakAppKit/OakAppKit.h>
#import <OakAppKit/OakUIConstructionFunctions.h>
#import <OakAppKit/NSImage Additions.h>

static NSButton* OakCreateImageButton (NSImage* image)
{
	NSButton* res = [NSButton new];
	[res setButtonType:NSButtonTypeMomentaryChange];
	[res setBordered:NO];
	[res setImage:image];
	[res setImagePosition:NSImageOnly];
	[res setContentTintColor: [NSColor secondaryLabelColor]];
	return res;
}

@implementation OFBActionsView
- (id)initWithFrame:(NSRect)aRect
{
	if(self = [super initWithFrame:aRect])
	{
		self.wantsLayer   = YES;
		self.material     = NSVisualEffectMaterialWindowBackground;
		self.blendingMode = NSVisualEffectBlendingModeWithinWindow;
		self.state        = NSVisualEffectStateFollowsWindowActiveState;

		self.createButton       = OakCreateImageButton([NSImage imageNamed:NSImageNameAddTemplate]);
		self.actionsPopUpButton = OakCreateActionPopUpButton();
		[self.actionsPopUpButton setContentTintColor: [NSColor secondaryLabelColor]];
		self.reloadButton       = OakCreateImageButton([NSImage imageNamed:NSImageNameRefreshTemplate]);
		self.searchButton       = OakCreateImageButton([NSImage imageNamed:@"SearchTemplate" inSameBundleAsClass:[self class]]);
		self.favoritesButton    = OakCreateImageButton([NSImage imageNamed:@"FavoritesTemplate" inSameBundleAsClass:[self class]]);
		self.scmButton          = OakCreateImageButton([NSImage imageNamed:@"SCMTemplate" inSameBundleAsClass:[self class]]);

		self.createButton.toolTip       = @"Create new file";
		self.reloadButton.toolTip       = @"Reload file browser";
		self.searchButton.toolTip       = @"Search current folder";
		self.favoritesButton.toolTip    = @"Show favorites";
		self.scmButton.toolTip          = @"Show source control management status";

		self.reloadButton.image.accessibilityDescription    = self.reloadButton.toolTip;
		self.createButton.image.accessibilityDescription    = self.createButton.toolTip;
		self.searchButton.image.accessibilityDescription    = self.searchButton.toolTip;
		self.favoritesButton.image.accessibilityDescription = self.favoritesButton.toolTip;
		self.scmButton.image.accessibilityDescription       = self.scmButton.toolTip;

		NSView* wrappedActionsPopUpButton = [NSView new];
		OakAddAutoLayoutViewsToSuperview(@[ self.actionsPopUpButton ], wrappedActionsPopUpButton);
		[wrappedActionsPopUpButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[popup]|" options:0 metrics:nil views:@{ @"popup": self.actionsPopUpButton }]];
		[wrappedActionsPopUpButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[popup]|" options:0 metrics:nil views:@{ @"popup": self.actionsPopUpButton }]];

		NSView* divider = OakCreateDividerImageView();

		NSDictionary* views = @{
			@"create":    self.createButton,
			@"divider":   divider,
			@"actions":   wrappedActionsPopUpButton,
			@"reload":    self.reloadButton,
			@"search":    self.searchButton,
			@"favorites": self.favoritesButton,
			@"scm":       self.scmButton,
		};

		OakAddAutoLayoutViewsToSuperview([views allValues], self);
		OakSetupKeyViewLoop(@[ self, _createButton, _actionsPopUpButton, _reloadButton, _searchButton, _favoritesButton, _scmButton ], NO);

		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[create]-[divider]-[actions(==31)]-(>=8)-[reload]-8-[search]-8-[favorites]-8-[scm]-(9)-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[divider(==reload)]|"                                                                               options:0 metrics:nil views:views]];

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
