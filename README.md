# excamera-ios

## 環境について

* iOS `~> 10.0`
* Xcode `10.1`
* [Homebrew](https://brew.sh) `~> 1.8.0`
* [Bundle](https://bundler.io) `~> 1.16.5`
* [Mint](https://github.com/yonaskolb/Mint) `~> 0.11.3`
* [CocoaPods](https://github.com/CocoaPods/CocoaPods) `~> 1.5.3`
* [Carthage](https://github.com/Carthage/Carthage) `~> 0.31.1`
* [XcodeGen](https://github.com/yonaskolb/XcodeGen) `~> 1.11.2`

### 環境の構築

#### Homebrew

```
$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

### Homebrew/bundle

```
$ brew tap Homebrew/bundle
```

### Bundle

```
$ gem install bundler
```

### 環境構築手順

```
$ brew bundle
$ mint bootstrap
$ carthage update --platform ios --cache-builds
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


