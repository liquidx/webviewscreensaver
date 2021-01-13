# WebViewScreenSaver
[![Build](https://img.shields.io/github/workflow/status/liquidx/webviewscreensaver/CI)](https://github.com/liquidx/webviewscreensaver/actions)
[![GitHub release](https://img.shields.io/github/v/release/liquidx/webviewscreensaver)](https://github.com/liquidx/webviewscreensaver/releases)

A macOS screen saver that displays a web page or a series of web pages.

## Installation

* Using [brew](https://brew.sh/)

``` bash
brew cask install webviewscreensaver
```
Or with brew >= [2.7.0](https://news.ycombinator.com/item?id=25528475) use
``` bash
brew install --cask  webviewscreensaver
```

* Directly from the [releases](https://github.com/liquidx/webviewscreensaver/releases) page. Just unpack and double click to install.

**Note**: Our package is **unsigned** and will remain like that for the foreseeable future.

When opening it up for the first time you will be prompted that *the developer cannot be verified*. <br />
Hit **cancel**, go to **Security and Privacy** where there should be a section explaining that "WebViewScreenSaver.saver" was blocked and an **Open Anyway** button next to it. Click that. <br />
Upon returning to the screensaver options an **Open** button should now be available which will remove security prompts until a future update.

**Alternatively**:
* if you are using [brew](https://brew.sh/) pass in `--no-quarantine` option to `install` or `reinstall` command.

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
