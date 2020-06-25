# excamera-ios

## Setup 

```
$ gem install fastlane
$ bundle install --path .bundle
$ bundle exec fastlane init
```

## Start Development 

```
$ brew bundle
$ carthage build --platform iOS --cache-builds
$ bundle install --path .bundle
$ bundle exec fastlane bootstrap
```

## Crashlytics integration

- https://github.com/ogawa0147/cloud-functions
- https://github.com/firebase/functions-samples/tree/master/crashlytics-integration/slack-notifier
- https://firebase.google.com/docs/functions/crashlytics-events?hl=ja
- https://firebase.googleblog.com/2019/09/how-to-set-up-crashlytics-alerting.html
- https://firebase.google.com/docs/crashlytics/extend-with-cloud-functions
