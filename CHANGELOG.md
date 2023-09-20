# Changelog

## [1.5.0] - 20.09.2023

- Fix: Flights were sorted incorrectly for the same departure date.
- New: Added attachments for the flight records.

## [1.4.0] - 20.07.2023

- Update: Redesign a synchronization process with the main app.

## [1.3.0] - 19.04.2023

- Update: A new algorithm for a night-time calculation. The previous one had a few limitations, such as it couldn't correctly calculate the time if the flight started before sunset and ended after sunrise. Or there was quite a high error if the flight was close to the North or South poles. The new algorithm divides the flight for the segments <5 minutes and checks the sunrise/sunset time for each of them, and then summarises the total night time.

## [1.2.2] - 18.04.2023

- Update: slightly improved user interface for the flight records

## [1.1.0] - 13.04.2023

- New: Added night-time calculation. The time can be slightly different (1-3 minutes) compared with the main logbook application. It's due to different libraries being used for calculating sunsets and sunrises.

## [1.0.1] - 06.04.2023

- First version of the mobile app for Android with simple functions: list the flight records, add/update flight record, and synchronize them with the main application