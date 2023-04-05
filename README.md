## Web Logbook Mobile

This mobile application is a sort of addon to the main [Web Logbook](https://github.com/vsimakhin/web-logbook/). The app is written in the Flutter framework and Dart programming language, using ChatGPT.

![image](https://user-images.githubusercontent.com/139220/229900051-58702257-17c0-4c3b-a328-3580a817d366.png)

The synchronization with the main application is bidirectional. So any changes on one or the other side should be synced. You can use as many mobile apps as you want.

# Changelog

The changelog is [here](https://github.com/vsimakhin/web-logbook-mobile/blob/main/CHANGELOG.md)

# Usage

1. Download the latest release from https://github.com/vsimakhin/web-logbook-mobile/releases for your mobile OS and install it
2. Check the server sync settings in the main Web Logbook application `Settings`->`Sync` and update the server address on the `Settings` page of the mobile app
3. Run `Sync`

# Supported OS

Android is for sure, and iOS is coming.

# Interface

* List of the flight records
* Add new or update the existing flight record
  * Double tap on the icon for the `PIC Name` field will put `Self`
  * Double tap on any icon for the time field will copy value from `Total time`
* Settings
  * Set server address
  * Define username and password in case your main application requires authorization

# Limitations

The app currently cannot calculate night time for the flight. So you will need to recalculate it in the main app in case.

# ToDo

- Build an app for iPhone
- Check a nighttime calculation
- Add some simple stats

