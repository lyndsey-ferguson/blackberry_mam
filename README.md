# blackberry_mam plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-blackberry_mam)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-blackberry_mam`, add it to your project by running:

```bash
fastlane add_plugin blackberry_mam
```

## About blackberry_mam

A fastlane plugin that works with Blackberry Dynamics (formerly Good Dynamics) provides Mobile Application Management. It includes
the following actions:

- blackberry_mam_network_check: checks to see if the required network ports for BlackBerry Dynamics are open on the network
- blackberry_mam_version_action: checks the version of the installed Good framework
- update_info_plist_for_blackberry_mam: updates the plist so that the built application can be deployed and managed within BlackBerry's Good Dynamics Control Center for Enterprise Mobility Management

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
