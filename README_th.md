# Gitanjali (Sri Gaudiya Gitanjali)

[Русский](./README.md) | [English](./README_en.md)

โครงการย้ายและปรับปรุงระบบ (Migration & Refactoring) ของแอปพลิเคชันอ่านหนังสือและเพลงสวดออฟไลน์ **Sri Gaudiya Gitanjali** จากแอป iOS เดิม (Swift/Objective-C) ไปยัง **Flutter** ซึ่งเป็นเทคโนโลยีครอสแพลตฟอร์มสมัยใหม่

## ภาพรวมโครงการ

แอปพลิเคชันนี้ให้การเข้าถึงเนื้อหาของ Sri Gaudiya Gitanjali แบบออฟไลน์ โดยมีฟีเจอร์หลักดังนี้:
- การอ่านเนื้อหาเพลงและบทสวด (อ้างอิงจากไฟล์ XML)
- การเล่นเสียง (Audio playback)
- การค้นหาเนื้อหา
- การคั่นหน้า (Bookmarks) และการบันทึกสถานะการอ่าน

## โครงสร้างพื้นที่เก็บข้อมูล (Repository Structure)

- `app/gitanjali/`: แอปพลิเคชันหลักที่พัฒนาด้วย Flutter (กำลังดำเนินการ)
- `legacy/legacy_gitanjajali_swift/`: ซอร์สโค้ดของแอปพลิเคชัน iOS เดิม
- `flows/`: เอกสารประกอบกระบวนการย้ายระบบ (ข้อกำหนด, รายละเอียดทางเทคนิค, ADR)

## เทคโนโลยีที่ใช้

- **Framework:** Flutter (Dart)
- **Content:** การแยกวิเคราะห์ XML (XML parsing)
- **Architecture:** Clean Architecture (ชั้นข้อมูล, โดเมน, และการนำเสนอ)
- **Features:** เครื่องเล่นเสียง, การค้นหาภายในเครื่อง, การคั่นหน้า
