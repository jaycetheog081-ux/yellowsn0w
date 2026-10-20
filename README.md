# yellowsn0w

yellowsn0w is a standalone iOS customization app written in Objective-C.

It provides a stock-iOS customization interface with an experimental
capability layer for detecting available features and environments.

## Project goals

- Written in Objective-C using `.h` and `.m` files.
- Generated Xcode project using XcodeGen and `project.yml`.
- Built with GitHub Actions.
- Supports iPhone and iPad.
- Minimum deployment target: iOS 15.0.
- Intended compatibility range: iOS 15.0 through iOS 27.0.1.
- Standalone; it does not depend on hurr1c4ne.

Compatibility with each iOS release and device must be verified through
testing. Setting a deployment target does not guarantee compatibility
with every newer release.

## Features

- Device and operating-system information.
- Theme configuration.
- Customization settings.
- Capability and environment checks.
- Package-management interface foundation.
- Import support for customization resources where supported by iOS.

## Important limitations

An ordinary, non-jailbroken iOS application cannot freely change
system-wide interface elements, modify protected system files, install
arbitrary system packages, or obtain root privileges.

Features that require additional privileges or unsupported APIs are
reported as unavailable rather than being represented as working.

The GitHub Actions workflow produces an **unsigned IPA**. An unsigned IPA
is not ready for ordinary installation on a stock device. Installation
requires an appropriate signing and provisioning method.

## Repository structure

```text
yellowsn0w/
├── .github/
│   └── workflows/
│       └── build.yml
├── yellowsn0w/
│   ├── AppDelegate.h
│   ├── AppDelegate.m
│   ├── DeviceInfo.h
│   ├── DeviceInfo.m
│   ├── SettingsManager.h
│   ├── SettingsManager.m
│   ├── ThemeManager.h
│   ├── ThemeManager.m
│   ├── CapabilityChecker.h
│   ├── CapabilityChecker.m
│   ├── PackageManager.h
│   ├── PackageManager.m
│   ├── ViewController.h
│   └── ViewController.m
├── project.yml
└── README.md
