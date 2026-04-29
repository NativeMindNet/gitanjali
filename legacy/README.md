# Legacy Directory Overview

This folder keeps historical iOS codebases and resources used as migration sources.

## Subfolders

- `legacy-gitanjali-swift`  
  Main legacy iOS Gitanjali project (Objective-C era naming, despite folder name).  
  Includes `Gitanjali/Classes` app logic, `Gitanjali/Resources` XML/images/sounds, and `Gitanjali_appstore` store/icon packaging files.

- `legacy_gitanjajali_swift`  
  Duplicate snapshot of the same Gitanjali legacy project (folder name contains typo).  
  Used as the migration source of truth in existing SDD flow and Flutter asset import.

- `legacy-cookbook`  
  Older sister project with similar reader architecture and shared UI/data abstractions.  
  Useful as reference for controls, animations, and parsing behavior not obvious in the primary legacy app.

- `legacy-sgg-ru-v1`  
  Russian/localized legacy variant (`Sri Gaudiya Gitanjali` RU v1) with adapted resources/content.  
  Helpful for localization parity checks and additional animation/resource examples.

## Common Structure Inside Legacy Apps

Most legacy projects follow this pattern:

- `Classes/` - app/domain/UI code (`Data Core`, `Interface`, `Search`, animation targets/actions)
- `Resources/` - `example.xml`, images, sounds, icons
- `Thirdparty/` - bundled dependencies (for example `id3lib`)
- `books.xcodeproj` - Xcode project files
