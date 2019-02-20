## Dangerfile

# --------------------
# diff size
# --------------------
is_big_pr = git.lines_of_code > 500
if is_big_pr
  warn '修正が多すぎます。[PR]を小さく分割してください。'
end

# --------------------
# pr title
# --------------------
is_wip_for_title = github.pr_title.include? '[WIP]'
if is_wip_for_title
  warn '作業途中の[PR]です。作業が終わったらタイトルを変更してください。'
end

# --------------------
# pr labels
# --------------------
is_wip_for_label = github.pr_labels.include? 'wip'
if is_wip_for_label
  warn '作業途中の[PR]です。作業が終わったら[wip]ラベルを外してください。'
end

# --------------------
# base branch
# --------------------
is_to_master = github.branch_for_base == "master"
is_to_develop = github.branch_for_base == "develop"
is_to_release = !!github.branch_for_base.match(/release-[0-9]+\.[0-9]+\.[0-9]/)
is_from_master = github.branch_for_head == "master"
is_from_develop = github.branch_for_head == "develop"
is_from_release = !!github.branch_for_head.match(/release-[0-9]+\.[0-9]+\.[0-9]/)

# merge
if is_to_master && !is_from_release
  fail 'master branch へ merge 出来るのは release branch のみです。'
end

# --------------------
# pr assignee
# --------------------
if github.pr_json["assignee"].nil?
  warn 'この[PR]にアサインしてください。'
end

# --------------------
# run swiftlint
# --------------------
github.dismiss_out_of_range_messages
swiftlint.config_file = '.swiftlint.yml'
swiftlint.lint_all_files = true
swiftlint.lint_files inline_mode: true

# --------------------
# xcode summary
# --------------------
xcode_summary.ignored_files = 'Pods/**'
xcode_summary.report 'build/reports/errors.json'

# --------------------
# lgtm picture
# --------------------
lgtm.check_lgtm
