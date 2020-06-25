source "https://rubygems.org"

gem "fastlane"
gem "cocoapods"
gem "danger"
gem "danger-swiftlint"
gem "danger-xcode_summary"
gem "xcpretty-json-formatter"
gem "xcprofiler"
gem "dotenv"
gem "danger-lgtm"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
