# Understanding: Bhagavad Gita Application Data Model

> Entry point for data structure analysis of /legacy/csv

## Project Overview

This is a **Bhagavad Gita study application** with multilingual support. The data model supports:
- Multiple book editions/translations (Russian, English, German, Spanish)
- Original Sanskrit verses with transliterations and translations
- Word-by-word vocabulary breakdowns
- Chapter structure across 18 chapters of Bhagavad Gita
- Inspirational quotes from various authors
- Device analytics for mobile app users

## Entity Relationship Model

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           CONTENT DOMAIN                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌──────────────┐         ┌──────────────┐         ┌──────────────┐    │
│   │  Languages   │◄────────│    Books     │────────►│   Chapters   │    │
│   │──────────────│ 1    N  │──────────────│ 1    N  │──────────────│    │
│   │ Id (PK)      │         │ Id (PK)      │         │ Id (PK)      │    │
│   │ Name         │         │ LanguageId   │         │ BookId (FK)  │    │
│   │ Code (en/ru) │         │ Name         │         │ Name         │    │
│   └──────────────┘         │ Initials     │         │ Order        │    │
│         ▲                  └──────────────┘         └──────────────┘    │
│         │                                                   │            │
│         │                                                   │ 1          │
│         │                                                   ▼ N          │
│         │                                           ┌──────────────┐    │
│         │                                           │    Slokas    │    │
│         │                                           │──────────────│    │
│         │                                           │ Id (PK)      │    │
│         │                                           │ ChapterId    │    │
│         │                                           │ Name (verse#)│    │
│         │                                           │ Text (Skt)   │    │
│         │                                           │ Transcription│    │
│         │                                           │ Translation  │    │
│         │                                           │ Comment      │    │
│         │                                           │ Order        │    │
│         │                                           │ Audio        │    │
│         │                                           │ AudioSanskrit│    │
│         │                                           └──────────────┘    │
│         │                                                   │            │
│         │                                                   │ 1          │
│         │                                                   ▼ N          │
│         │                                           ┌──────────────┐    │
│         │                                           │ Vocabularies │    │
│         │                                           │──────────────│    │
│         │                                           │ Id (PK)      │    │
│         │                                           │ SlokaId (FK) │    │
│         │                                           │ Text (word)  │    │
│         │                                           │ Translation  │    │
│         │                                           └──────────────┘    │
│         │                                                                │
│   ┌─────┴────────┐                                                       │
│   │    Quotes    │                                                       │
│   │──────────────│                                                       │
│   │ Id (PK)      │                                                       │
│   │ LanguageId   │                                                       │
│   │ Author       │                                                       │
│   │ Text         │                                                       │
│   │ IsDay        │                                                       │
│   └──────────────┘                                                       │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                          ANALYTICS DOMAIN                                │
├─────────────────────────────────────────────────────────────────────────┤
│   ┌──────────────────┐                                                   │
│   │     Devices      │  (Standalone - no FK relationships)              │
│   │──────────────────│                                                   │
│   │ Id (PK, UUID)    │                                                   │
│   │ Platform         │  (1=Android, 2=iOS?)                              │
│   │ OsVersion        │                                                   │
│   │ DeviceId         │                                                   │
│   │ Model            │                                                   │
│   │ AppVersion       │                                                   │
│   │ TimezoneOffset   │                                                   │
│   │ Culture          │  (0/1 - locale flag?)                             │
│   │ PushToken        │                                                   │
│   │ LastModified     │                                                   │
│   └──────────────────┘                                                   │
└─────────────────────────────────────────────────────────────────────────┘
```

## Identified Domains

| Domain | Hypothesis | Priority | Status |
|--------|------------|----------|--------|
| content | Core spiritual content - verses, translations, vocabulary | HIGH | EXPLORING |
| localization | Multi-language support (4 languages) | MEDIUM | EXPLORING |
| analytics | User device tracking for mobile app | LOW | EXPLORING |

## Entity Schemas (Detailed)

### 1. Languages (db_languages.csv)
```
Columns: Id, Name, Code
Delimiter: ,
Records: 4
```
| Id | Name | Code |
|----|------|------|
| 1 | English | en |
| 2 | Русский | ru |
| 3 | Deutsch | de |
| 5 | Español | spa |

**Note**: Id=4 is missing - suggests possible deleted language.

---

### 2. Books (db_books.csv)
```
Columns: Id, LanguageId, Name, Initials
Delimiter: ,
Records: 6
```
| Id | LanguageId | Name | Initials |
|----|------------|------|----------|
| 1 | 2 (ru) | Бхагавад Гита Жемчужина мудрости Востока | ШМ |
| 2 | 1 (en) | Bhagavad-gītā. The Hidden Treasure of the Sweet Absolute | SM |
| 5 | 1 (en) | Visvanath Cakravarti Thakur commentary | VC |
| 8 | 1 (en) | Srimad Bhagavad-Gītā As It Is (Prabhupada) | SP |
| 11 | 3 (de) | Die BHAGAVAD-GITA in Deutsch | SM |
| 14 | 5 (spa) | Śrīmad Bhagavad-Gītā | SM |

**Initials Legend**:
- **SM** = Sridhar Maharaj
- **VC** = Visvanath Cakravarti
- **SP** = Swami Prabhupada

---

### 3. Chapters (db_chapters.csv)
```
Columns: Id, BookId, Name, Order
Delimiter: ,
Records: 143 (18 chapters × ~8 book editions, some with multiline names)
```

Each book has 18 chapters. Chapter names vary by translation:
- Russian: "Осмотр Армий", "Душа в мире материи"...
- English: "Observing the Armies", "The Constitution of the Soul"...
- German: Multiline format with Sanskrit names

**Note**: German chapters (BookId=11) have embedded newlines in Name field.

---

### 4. Slokas (Gita_Slokas.csv) - **CORE CONTENT**
```
Columns: Id, ChapterId, Name, Text, Transcription, Translation, Comment, Order, Audio, AudioSanskrit
Delimiter: ;
Records: 700+ (all verses of Bhagavad Gita)
```

| Column | Description |
|--------|-------------|
| Id | Primary key |
| ChapterId | FK to Chapters |
| Name | Verse number (e.g., "1.1", "1.2", "1.4-6") |
| Text | Original Sanskrit in Devanagari script |
| Transcription | IAST transliteration with diacritics (Russian-style) |
| Translation | Full verse translation |
| Comment | Commentary (NULL for most) |
| Order | Display order within chapter |
| Audio | Path to audio file (/Files/*.mp3) |
| AudioSanskrit | Path to Sanskrit recitation audio |

**Example Sloka**:
- Verse 1.1: धृतराष्ट्र उवाच... (Dhritarashtra spoke...)
- Includes both reading and Sanskrit pronunciation audio

---

### 5. Vocabularies (Gita_Vocabularies.csv)
```
Columns: Id, SlokaId, Text, Translation
Delimiter: ;
Records: 5000+ (word-by-word breakdown)
```

Word-by-word vocabulary for each sloka:
- **SlokaId**: Links to specific verse
- **Text**: Sanskrit/transliterated word
- **Translation**: Word meaning

Example for Sloka 1:
| Text | Translation |
|------|-------------|
| дхр̣тара̄ш̣т̣рах̣ ува̄ча | Дхр̣тара̄ш̣т̣ра сказал |
| дхарма-кш̣етре куру-кш̣етре | на священной земле Курукш̣етры |

---

### 6. Quotes (db_quoutes.csv)
```
Columns: Id, LanguageId, Author, Text, IsDay
Delimiter: ,
Records: 150+
```

Inspirational quotes about Bhagavad Gita from notable figures:
- **Authors**: Gandhi, Tolstoy, Einstein, Huxley, Thoreau, Schopenhauer, etc.
- **Languages**: English (1), Russian (2), German (3)
- **IsDay**: Boolean flag (0/1) - likely "quote of the day" feature

---

### 7. Devices (Gita_Devices.csv)
```
Columns: Id, Platform, OsVersion, DeviceId, Model, AppVersion, TimezoneOffset, Culture, PushToken, LastModified
Delimiter: ;
Records: 50,000+
```

Mobile app analytics data:
- **Platform**: 1 = Android (all observed records)
- **OsVersion**: Android versions (5.0 - 11)
- **Model**: Samsung, Xiaomi, OnePlus, Huawei, etc. (predominantly Indian market devices)
- **PushToken**: Firebase Cloud Messaging tokens
- **LastModified**: 2018-2022 range

---

## Source Mapping

| Source Path | -> Domain |
|-------------|----------|
| Books/db_languages.csv | localization |
| Books/db_books.csv | content → books |
| Books/db_chapters.csv | content → chapters |
| Books/Gita_Slokas.csv | content → slokas |
| Books/Gita_Vocabularies.csv | content → vocabularies |
| Books/db_quoutes.csv | content → quotes |
| devices/Gita_Devices.csv | analytics → devices |

## Cross-Cutting Concerns

> Things that span multiple domains (may become ADRs)

1. **File Naming Inconsistency**: Mix of `db_*.csv` and `Gita_*.csv` naming conventions
2. **Delimiter Inconsistency**: Some files use `;` (semicolon), others use `,` (comma)
3. **ID Gaps**: Missing IDs in sequences (e.g., Language Id=4, Book Ids 3,4,6,7,9,10,12,13)
4. **Multiline Values**: German chapter names contain embedded newlines
5. **Audio File References**: Paths reference `/Files/*.mp3` - external storage
6. **Encoding**: Files use UTF-8 with BOM (﻿ marker)

## Children Spawned

```
understanding/
└── data-model/
    ├── content-domain/
    │   ├── _node.md (books, chapters, slokas, vocabularies, quotes)
    │   └── relationships.md
    └── analytics-domain/
        └── _node.md (devices)
```

## Data Statistics Summary

| Entity | Records | Primary Language |
|--------|---------|------------------|
| Languages | 4 | - |
| Books | 6 | Multi (en, ru, de, spa) |
| Chapters | 143 | Multi |
| Slokas | ~700 | Russian translations |
| Vocabularies | ~5000 | Russian |
| Quotes | ~150 | English + Russian |
| Devices | ~50,000 | Analytics |

## Synthesis

This is a **mobile application database** for studying Bhagavad Gita with:

1. **Content Hierarchy**: Language → Book → Chapter → Sloka → Vocabulary
2. **Audio Support**: Each sloka has 2 audio files (reading + Sanskrit)
3. **Multi-edition**: Same verses available in different translations
4. **Vocabulary Learning**: Word-by-word breakdown for study
5. **Inspirational Quotes**: Daily quote feature with famous author quotes
6. **Mobile Analytics**: Android app with push notification support

**Technology Indicators**:
- Mobile-first (Android app with push tokens)
- Firebase integration (FCM tokens visible)
- Audio streaming capability
- Predominantly Indian market users

---

*Created by /legacy EXPLORING phase - 2026-03-26*
