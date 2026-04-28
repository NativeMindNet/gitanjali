# Gitanjali (Sri Gaudiya Gitanjali)

[Русский](./README.md) | [ไทย](./README_th.md)

A project focused on migrating and refactoring the **Sri Gaudiya Gitanjali** offline reader/songbook from a legacy iOS application (Swift/Objective-C) to a modern cross-platform **Flutter** stack.

## Project Overview

The application provides offline access to Sri Gaudiya Gitanjali content, featuring:
- Text browsing for songs and prayers (XML-based).
- Audio playback.
- Content search.
- Bookmarks and reading state persistence.

## Repository Structure

- `app/gitanjali/`: The main Flutter application (under development).
- `legacy/legacy_gitanjajali_swift/`: Source code of the original iOS application.
- `flows/`: Documentation of the migration process (Requirements, Specifications, ADR).

## Tech Stack

- **Framework:** Flutter (Dart)
- **Content:** XML parsing
- **Architecture:** Clean Architecture (Data, Domain, Presentation layers)
- **Features:** Audio player, Local search, Bookmarks.
