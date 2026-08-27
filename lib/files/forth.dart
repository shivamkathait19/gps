class AppLanguage {
  static String currentLocaleCode = 'en';

  static final Map<String, Map<String, String>> translations = {
    "en": {
      "next": "Next",
      "title": "Choose your preferred language",
      "subtitle": "From the below languages, Please choose your native language.",
      "gps_active": "GPS ACTIVE",
      "save_photo": "Save Photo",
      "retake": "Retake",
      "share": "Share",
      "captured_gps_photo": "Captured GPS Photo",
      "note": "Note: GPS Map Camera Photo",
    },
    "id": {
      "next": "Berikutnya",
      "title": "Pilih bahasa Anda",
      "subtitle": "Silakan pilih bahasa asli Anda dari bahasa di bawah ini.",
      "gps_active": "GPS AKTIF",
      "save_photo": "Simpan Foto",
      "retake": "Ambil Ulang",
      "share": "Bagikan",
      "captured_gps_photo": "Foto GPS Ditangkap",
      "note": "Catatan: Foto Kamera Peta GPS",
    },
    "hi": {
      "next": "आगे बढ़ें",
      "title": "अपनी पसंदीदा भाषा चुनें",
      "subtitle": "नीचे दी गई भाषाओं में से अपनी भाषा चुनें।",
      "gps_active": "GPS चालू",
      "save_photo": "फोटो सेव करें",
      "retake": "दोबारा लें",
      "share": "शेयर करें",
      "captured_gps_photo": "GPS फोटो कैप्चर",
      "note": "नोट: GPS मैप कैमरा फोटो",
    },
    "es": {
      "next": "Siguiente",
      "title": "Elige tu idioma",
      "subtitle": "Seleccione su idioma preferido.",
      "gps_active": "GPS ACTIVO",
      "save_photo": "Guardar Foto",
      "retake": "Retomar",
      "share": "Compartir",
      "captured_gps_photo": "Foto GPS Capturada",
      "note": "Nota: Foto de Cámara de Mapa GPS",
    },
    "th": {
      "next": "ถัดไป",
      "title": "เลือกภาษาของคุณ",
      "subtitle": "กรุณาเลือกภาษาแม่ของคุณจากภาษาด้านล่าง",
      "gps_active": "GPS ใช้งานอยู่",
      "save_photo": "บันทึกภาพ",
      "retake": "ถ่ายใหม่",
      "share": "แชร์",
      "captured_gps_photo": "ภาพ GPS ที่ถ่าย",
      "note": "หมายเหตุ: ภาพกล้องแผนที่ GPS",
    },
  };

  static String text(String key) {
    return translations[currentLocaleCode]?[key] ?? key;
  }
}