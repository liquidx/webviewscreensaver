# WebViewScreenSaver
[![Build](https://img.shields.io/github/workflow/status/liquidx/webviewscreensaver/CI)](https://github.com/liquidx/webviewscreensaver/actions)
[![GitHub release](https://img.shields.io/github/v/release/liquidx/webviewscreensaver)](https://github.com/liquidx/webviewscreensaver/releases)

A macOS screen saver that displays a web page or a series of web pages.

## Installation

* Using [brew](https://brew.sh/).&#42;

``` bash
brew install --cask webviewscreensaver
```

* Directly from the [releases](https://github.com/liquidx/webviewscreensaver/releases) page. Unpack and double click to install.&#42;

* From source (requires [Xcode](https://developer.apple.com/xcode/)):
``` bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/liquidx/webviewscreensaver/master/install-from-source.sh)"
```

**&#42;Note**: The package is **adhoc signed** (since v2.2.1, previously unsigned).

When opening it the first time you will get a security prompt about Apple not being able to verify the software. <br />
Hit **ok** (cancel in older macOS) and go to **Security and Privacy**.<br />
In the section explaining that "WebViewScreenSaver.saver" was blocked click **Open Anyway**.<br />
Upon returning to screensaver options you'll get a second prompt that can be confirmed by clicking **Open**.

**Alternatively**:

* if you are using [brew](https://brew.sh/) pass in `--no-quarantine` option to `install` or `reinstall` command:
``` bash
brew install --cask webviewscreensaver --no-quarantine
```

* or if you installed it via direct download run the folllowing command to remove the file from quarantine:
``` bash
xattr -d com.apple.quarantine WebViewScreenSaver.saver
```

## Configuration

Open up System Preferences > **Desktop and Screen Saver** > Screen Saver and **WebViewScreenSaver** should be at the end of the list.

In the addresses section fill in as many websites as you want the screensaver to cycle through and the amount of time to pause on each.

**Tip**: To edit a **selected** row, click **once** or tap **Enter** or **Tab**.

Passing in a negative time value e.g. `-1` will notify the screensaver to remain on that website indefinitely.

Need some website ideas? Check out suggestions in the [examples](examples.md) section.

Local **absolute** paths can also be used as an address with or without the `file://` schema.

E.g. `file:///Users/myUser/mySreensaver/index.html`

**Note**: If you are running **Catalina** or newer the provided path cannot reside in your personal folders which require extra permissions (this includes things like *Downloads*, *Documents* or *Desktop*) but can be anywhere else in your user's folder.

### Configuration for IT
If you are interested in scripting configuration changes, WebViewScreenSaver, like most other screensavers, makes use of the macOS `defaults` system.

This can be queried and updated via:
``` bash
defaults -currentHost read WebViewScreensaver
```
or directly *(if installed for current user or should find it in `/Library` otherwise)*
``` bash
/usr/libexec/PlistBuddy -c 'Print' ~/Library/Preferences/ByHost/WebViewScreenSaver.*
```

## License
Code is licensed under the [Apache License, Version 2.0 License](LICENSE.md).
