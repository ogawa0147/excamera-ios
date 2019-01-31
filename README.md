# ExCamera

## Requirements

* iOS `~> 10.0`
* Xcode `10.1`
* [Homebrew](https://brew.sh) `~> 1.8.0`
* [Bundle](https://bundler.io) `~> 1.16.5`
* [CocoaPods](https://github.com/CocoaPods/CocoaPods) `~> 1.5.3`
* [Carthage](https://github.com/Carthage/Carthage) `~> 0.31.1`
* [XcodeGen](https://github.com/yonaskolb/XcodeGen) `~> 1.11.2`

## Installation

### Homebrew

```
$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

### Bundle

```
$ gem install bundler
```

### CocoaPods

```
$ gem install cocoapods
```

### Carthage

```
$ brew install carthage
```

### XcodeGen

```
$ brew install xcodegen
```

## Start development 

```
$ carthage bootstrap --platform ios --cache-builds
$ bundle install --path .bundle
$ bundle exec fastlane bootstrap
```

### `Fastlane`から`Fabric`へアップロードする準備をする

- `.env.example`をコピーして`.env`を生成する
- `Fabric`の`API Token`を`.env`に追記する

```
CRASHLYTICS_API_TOKEN=
CRASHLYTICS_BUILD_SECRET=
```

### `Fastlane`から`Fabric`へアップロードする

```
$ bundle exec fastlane beta
```


