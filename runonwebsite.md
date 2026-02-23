ขั้นตอนอัปเดตเว็บเมื่อมีการแก้โค้ด:
สร้างไฟล์เว็บเวอร์ชันใหม่:
ใน Terminal ของ VS Code พิมพ์คำสั่งเดิมเพื่อให้ Flutter แปลงโค้ดที่คุณเพิ่งแก้ให้เป็นไฟล์เว็บ:

Bash
flutter build web
อัปโหลดขึ้นไปทับของเดิม (Deploy):
พิมพ์คำสั่งส่งไฟล์ขึ้นไปที่ Firebase Hosting:

Bash
firebase deploy --only hosting
