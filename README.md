# WebViewScreenSaver
[![Build](https://img.shields.io/github/actions/workflow/status/liquidx/webviewscreensaver/ci.yml?branch=master)](https://github.com/liquidx/webviewscreensaver/actions)
[![GitHub release](https://img.shields.io/github/v/release/liquidx/webviewscreensaver)](https://github.com/liquidx/webviewscreensaver/releases)

A macOS screen saver that displays a web page or a series of web pages.

> [!WARNING]
> If the Options button doesn't do anything on macOS 26 Tahoe close and reopen System Settings. This seems to be an OS-level bug with no known code workaround.

## Installation

* Using [brew](https://brew.sh/).&#42;

``` bash
brew install --cask webviewscreensaver --no-quarantine
```

* Directly from the [releases](https://github.com/liquidx/webviewscreensaver/releases) page. Unpack and double click to install.&#42;

* From source (requires [Xcode](https://developer.apple.com/xcode/)):
``` bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/liquidx/webviewscreensaver/master/install-from-source.sh)"
```

**&#42;Note**: The package is **adhoc signed** (since v2.2.1, previously unsigned).

`--no-quarantine` disables macOS's Gatekeeper during installation.

Otherwise when opening it the first time you will get multiple security prompts about Apple not being able to verify the software. <br />
Hit **ok** (cancel in older macOS) and go to **Privacy & Security** and scroll to bottom.<br />
You'll find a section explaining that "WebViewScreenSaver.saver" was blocked click **Open Anyway**.<br />
Upon returning to screensaver options you'll get a second prompt that can be confirmed by clicking **Open**.

**Alternative** if you installed it via direct download run the folllowing command to remove the file from quarantine:
``` bash
xattr -d com.apple.quarantine WebViewScreenSaver.saver
```

## Configuration

Open up System Preferences > **Desktop and Screen Saver** > Screen Saver and **WebViewScreenSaver** should be at the end of the list.

In the addresses section fill in as many websites as you want the screensaver to cycle through and the amount of time to pause on each.

**Tip**: To edit a **selected** row, click **once** or tap **Enter** or **Tab**.

Passing in a negative time value e.g. `-1` will notify the screensaver to remain on that website indefinitely.

Need some website ideas? Check out suggestions in the [examples](examples.json). (feel free to suggest others)

The example file can also be used with the **fetch URLs** feature: `https://raw.githubusercontent.com/liquidx/webviewscreensaver/master/examples.json`

Local **absolute** paths can also be used as an address with or without the `file://` schema.

E.g. `file:///Users/myUser/mySreensaver/index.html`

**Note**: If you are running **Catalina** or newer the provided path cannot reside in your personal folders which require extra permissions (this includes things like *Downloads*, *Documents* or *Desktop*) but can be anywhere else in your user's folder.

### Configuration for IT
If you are interested in scripting configuration changes, WebViewScreenSaver, like most other screensavers, makes use of the macOS `defaults` system.

This can be queried and updated via:
``` bash
/usr/libexec/PlistBuddy -c 'Print' ~/Library/Containers/com.apple.ScreenSaver.Engine.legacyScreenSaver/Data/Library/Preferences/ByHost/WebViewScreenSaver.*.plist
```

Depending on how it was installed, which macOS version and which architecture you are running you might find the plist under the following paths:
```bash
ls ~/Library/Containers/com.apple.ScreenSaver.Engine.legacyScreenSaver/Data/Library/Preferences/ByHost/WebViewScreenSaver.*
ls ~/Library/Containers/com.apple.ScreenSaver.Engine.legacyScreenSaver/Data/Library/Preferences/net.liquidx.WebViewScreenSaver
ls ~/Library/Containers/com.apple.ScreenSaver.Engine.legacyScreenSaver-x86_64/Data/Library/Preferences/net.liquidx.WebViewScreenSaver
ls ~/Library/Preferences/ByHost/WebViewScreenSaver.* # Pre macOS 10.15
```

Any .plist editor can be used including built-in `PlistBuddy` and `plutil`.

## License
Code is licensed under the [Apache License, Version 2.0 License](LICENSE.md).
