FadeCandy-QC-Plugin
===================

FadeCandyQC is a Quartz Composer plugins that lets you output visuals to a locally running [FadeCandy](https://github.com/scanlime/fadecandy) server. 

(You'll need a FadeCandy board or comparable Teensy running the Fadecandy software, and an Apple Developer account.)


Directions:
=======

1. Download and install [Quartz Composer](https://developer.apple.com/downloads/index.action?name=Graphics).
2. Install [CocoaPods](http://cocoapods.org).
3. `cd` to the FadeCandyQC folder, then run `pod install`.
4. Open the FadeCandyQC.xcworkspace (not the .xcodeproj), and run. The Quartz Composer app should launch. You can select the FadeCandyQC plugin from the Library window.


Todo:
=====

Hook up the SettingsViewController, and verify the code works on different sized LED boards. (Right now we're making some hardcoded assumptions about the size of the board.)