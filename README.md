# ExCamera

### `xcodeproj`を生成して開発環境を用意する

```
$ bundle install
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


