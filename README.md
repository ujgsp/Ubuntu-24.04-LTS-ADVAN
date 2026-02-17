# Ubuntu-24.04-LTS-ADVAN

# History Perbaikan Audio Advan 1701

## Masalah Utama
- Sound output (Speaker) dan input (Microphone) tidak berfungsi.
- Sistem mendeteksi "Headphones" selalu terpasang (Phantom Jack).
- Konflik file konfigurasi di `/etc/modprobe.d/`.

## Langkah yang Telah Diambil
1.  **Analisis Hardware**: Codec ALC269VB, Controller Ice Lake-LP.
2.  **Analisis Software**: Ditemukan 3 file modprobe yang saling bentrok (`alsa-advan.conf`, `alsa-advan-fix.conf`, `alsa-base.conf`).
3.  **Tindakan Mandiri User**: User memilih untuk menjalankan perintah perbaikan secara manual demi keamanan password.

## Instruksi Manual Untuk User
Jalankan perintah berikut di terminal Anda:

1.  `sudo rm -f /etc/modprobe.d/alsa-advan.conf /etc/modprobe.d/alsa-advan-fix.conf`
2.  `sudo sed -i 's/model=laptop-dmic/model=clevo-p150sm/' /etc/modprobe.d/alsa-base.conf`
3.  `sudo reboot`

**Catatan**: Jika `clevo-p150sm` tetap tidak berhasil, Anda bisa mencoba menggantinya dengan `alc269-vcc` atau `alc269-inv-dmic` pada langkah ke-2.

## Update 17 Februari 2026 (Lanjutan)
1.  **Status Awal**: Konfigurasi `clevo-p150sm` sudah aktif, namun Speaker masih bisu (0% & muted) dan Microphone `test-mic-pw.wav` kosong (0 bytes data).
2.  **Perbaikan Speaker**: Berhasil di-unmute dan volume diset ke 80% menggunakan `amixer`.
3.  **Verifikasi Mic**: Berhasil merekam suara (`test-mic-new.wav`) yang dikonfirmasi memiliki sinyal audio (bukan hening).
4.  **Masalah Tersisa**: "Phantom Jack" (Headphone & Mic Jack terdeteksi selalu ON) masih terjadi pada model `clevo-p150sm` dan `laptop-amic`. Ini menyebabkan Speaker dan Internal Mic dianggap "Unavailable" oleh PulseAudio/PipeWire.
5.  **Hasil alc269-vcc**: Setelah reboot, audio (output & input) menjadi "unavailable" di pavucontrol.
6.  **Tindakan Terbaru**: Konfigurasi di `/etc/modprobe.d/alsa-base.conf` diubah ke `laptop-amic`. Hasilnya: Audio terdeteksi, namun "Phantom Jack" tetap ada.
7.  **Rencana Selanjutnya**: Melakukan override pada Pin 0x18 (Mic) dan 0x21 (Headphones) untuk menonaktifkan deteksi kehadiran (`NO_PRESENCE`).
    - Pin 0x18: `0x04a19030` -> `0x04a19130`
    - Pin 0x21: `0x04211020` -> `0x04211120`
8.  **File Perbaikan**: Telah dibuat script `fix-step-2.sh` yang akan membuat file firmware `/lib/firmware/hda-advan.fw` dan memberikan instruksi update `alsa-base.conf`.

## Solusi Akhir (Berhasil - 17 Februari 2026)
Masalah audio pada Advan 1701 (Codec ALC269VB) berhasil diselesaikan sepenuhnya dengan langkah-langkah berikut:

1.  **Override Pin Configuration (Fix Phantom Jack)**:
    Dibuat file patch firmware di `/lib/firmware/hda-advan.fw` untuk mematikan deteksi jack otomatis yang salah (Phantom Jack) pada Pin 0x18 (Mic) dan 0x21 (Headphones).
    ```text
    [codec]
    0x10ec0269 0x1e507007 0

    [pincfg]
    0x18 0x04a19130
    0x21 0x04211120
    ```

2.  **Konfigurasi Modprobe Utama**:
    Mengatur parameter kernel untuk menggunakan model yang kompatibel dan memuat file patch firmware di atas.
    File: `/etc/modprobe.d/alsa-base.conf`
    Isi: `options snd-hda-intel model=laptop-amic patch=hda-advan.fw`

3.  **Status Akhir**:
    - **Speaker Internal**: Aktif dan jernih.
    - **Headphones**: Berfungsi normal.
    - **Microphone (Internal & External)**: Berfungsi normal dan dapat merekam suara.
    - **Phantom Jack**: Berhasil dihilangkan; sistem tidak lagi mendeteksi headphone dicolokkan secara terus-menerus.

Perbaikan selesai. File ini disimpan sebagai referensi jika sistem melakukan update kernel yang mungkin menimpa konfigurasi ini.
