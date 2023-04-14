## Web Logbook Mobile

This mobile application is a sort of addon to the main [Web Logbook](https://github.com/vsimakhin/web-logbook/). The app is written in the Flutter framework and Dart programming language, using ChatGPT.

The synchronization with the main application is bidirectional. So any changes on one or the other side should be synced. You can use as many mobile apps as you want.

## Changelog

The changelog is [here](https://github.com/vsimakhin/web-logbook-mobile/blob/main/CHANGELOG.md)

## Usage

1. Download the latest release from https://github.com/vsimakhin/web-logbook-mobile/releases for your mobile OS and install it. You always can build the app yourself - check Flutter [install](https://docs.flutter.dev/get-started/install) and build instructions for [Android](https://docs.flutter.dev/deployment/android) and [iOS](https://docs.flutter.dev/deployment/ios).
2. Check the server sync settings in the main Web Logbook application `Settings`->`Sync` and update the server address on the `Settings` page of the mobile app
3. Run `Sync`

## Supported OS

Android is for sure, and iOS is coming.

## Interface

<table border="0">
 <tr>
 <td width=25%><img src="https://raw.githubusercontent.com/vsimakhin/web-logbook-assets/main/mobile/flight-records.jpg"></td>
 <td width=25%><img src="https://raw.githubusercontent.com/vsimakhin/web-logbook-assets/main/mobile/new-flight.jpg"></td>
 <td width=25%><img src="https://raw.githubusercontent.com/vsimakhin/web-logbook-assets/main/mobile/stats.jpg"></td>
 <td width=25%><img src="https://raw.githubusercontent.com/vsimakhin/web-logbook-assets/main/mobile/settings.jpg"></td>
 </tr>
</table>

* List of the flight records
* Add new or update the existing flight record
  * Double tap on the icon for the `PIC Name` field will put `Self`
  * Double tap on any icon for the time field will copy the value from `Total time`
  * Automatic night-time calculation (Airport database should be downloaded -> check `Settings` page)
* Stats
  * Flight totals for `This Month`, `This Year` and `All time`
* Settings
  * Set server address
  * Define username and password in case your main application requires authorization
  * Download the airport database. This includes default airfields, and your custom ones as well
