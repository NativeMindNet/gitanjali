# Gitanjali (Sri Gaudiya Gitanjali)

[English](./README_en.md) | [ไทย](./README_th.md)

Проект по миграции и рефакторингу полноценного офлайн-ридера/песенника **Sri Gaudiya Gitanjali** с устаревшего iOS-приложения (Swift/Objective-C) на современный кроссплатформенный стек **Flutter**.

## Обзор проекта

Приложение предоставляет доступ к контенту Sri Gaudiya Gitanjali в офлайн-режиме, включая:
- Чтение текстов песен и молитв (на основе XML-контента).
- Воспроизведение аудио.
- Поиск по контенту.
- Закладки и сохранение состояния чтения.

## Структура репозитория

- `app/gitanjali/`: Основное приложение на Flutter (в разработке).
- `legacy/legacy_gitanjajali_swift/`: Исходный код оригинального iOS-приложения.
- `flows/`: Документация процесса миграции (Requirements, Specifications, ADR).

## Технологический стек

- **Framework:** Flutter (Dart)
- **Content:** XML parsing
- **Architecture:** Clean Architecture (Data, Domain, Presentation layers)
- **Features:** Audio player, Local search, Bookmarks.
