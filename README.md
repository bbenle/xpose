# x_ray_simulator

Get assets from...
https://drive.google.com/drive/folders/1fk5xfVuZezEh7EMb03cfwXVW-G4p3ex0?usp=sharing

Android instructions
- Android Studio > files > Invalidate caches/restart (for android xlint errors)

iOS instructions
- Podfile -> uncomment the second line and change 9.0 to 10.0
- Add GoogleService-info.plist from iOS -> runner (must be added through xcode)
- Error: CocoaPods's specs repository is too out-of-date to satisfy dependencies.
    - https://stackoverflow.com/questions/64443888/flutter-cocoapodss-specs-repository-is-too-out-of-date-to-satisfy-dependencies
- error: No profiles for 'com.xRaySimulator' were found: Xcode couldn't find any iOS App Development provisioning
  profiles matching 'com.xRaySimulator'. Automatic signing is disabled and unable to generate a profile.
  To enable automatic signing, pass -allowProvisioningUpdates to xcodebuild. (in target 'Runner' from project 'Runner')
        - go to xcode
        - under runner, go to signing & capabilities
        - change team to Bcdj Curtin (Personal Team)
        - change bundle identifier to com.curtin.xRaySimulator

Running tests?
Mocks may need to be regenerated, use:
    flutter pub run build_runner build
    flutter pub run build_runner build --delete-conflicting-outputs
