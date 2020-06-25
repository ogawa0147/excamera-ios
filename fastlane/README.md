fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios bootstrap
```
fastlane ios bootstrap
```
Setup for development
### ios distribute
```
fastlane ios distribute
```
Submit a new Beta Build to App Distribution
### ios certificates
```
fastlane ios certificates
```
Sync certificates and profiles across team using git
### ios versions
```
fastlane ios versions
```
Show current command version
### ios update
```
fastlane ios update
```
Update command version

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
