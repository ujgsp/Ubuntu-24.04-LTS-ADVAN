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

## Update 17 Februari 2026 (Fix Noise Screen Recording)
Jika Anda mengalami noise (hissing/static) saat merekam menggunakan SimpleScreenRecorder:

1.  **Kurangi Mic Boost**:
    Hardware boost yang terlalu tinggi menyebabkan suara "desis".
    ```bash
    amixer -c 0 sset 'Internal Mic Boost' 1
    amixer -c 0 sset 'Capture' 80%
    ```

2.  **Gunakan Virtual "Clean Microphone" (PipeWire)**:
    Untuk menghilangkan noise secara real-time, buat source virtual:
    ```bash
    pactl load-module module-echo-cancel use_master_format=1 aec_method=webrtc source_name=noised_source sink_name=noised_sink source_properties=device.description=Clean_Microphone sink_properties=device.description=Clean_Output
    ```
    Di **SimpleScreenRecorder**, pilih Source: **Clean Microphone**.

3.  **Membuat Permanen**:
    Agar "Clean Microphone" selalu ada setelah restart, buat file konfig:
    `~/.config/pipewire/pipewire.conf.d/99-input-denoising.conf`
    ```text
    context.modules = [
    {   name = libpipewire-module-echo-cancel
        args = {
            source.props = {
                node.name = "noised_source"
                node.description = "Clean Microphone"
            }
            aec.args = {
                # Noise suppression settings
                "webrtc.noise_suppression" = true
                "webrtc.extended_filter" = true
            }
        }
    }
    ]
    ```

## Konfigurasi Aplikasi & Automasi
Setelah mengaktifkan "Clean Microphone", gunakan setelan berikut agar suara jernih:

1.  **SimpleScreenRecorder**:
    - **Audio Backend**: PulseAudio
    - **Source**: Clean Microphone (atau `noised_source`)

2.  **Aplikasi Lain (Discord, Telegram, Zoom, Browser)**:
    - Masuk ke **Settings > Voice/Audio**.
    - Ganti **Input Device** dari "Default" ke **Clean Microphone**.

3.  **Script Automasi (`fix-noise.sh`)**:
    Telah dibuat script untuk menjalankan langkah-langkah di atas secara otomatis:
    ```bash
    ./fix-noise.sh
    ```
    Script ini mengatur level mixer hardware dan membuat konfigurasi PipeWire permanen di direktori user.

## Update 23 Februari 2026 (Fix Buzzing & Noise di Discord)
1.  **Masalah**: Input mikrofon masih berdengung (buzzing) saat digunakan di Discord meskipun noise cancellation dasar sudah aktif.
2.  **Penyebab**: `Capture` (Gain) terlalu tinggi (100%/+30dB) dan kurangnya filter frekuensi rendah.
3.  **Tindakan**:
    - Menurunkan `Capture` ke **75%** (+22.50dB) untuk mengurangi noise floor.
    - Menambahkan `webrtc.high_pass_filter = true` untuk membuang dengungan (humming).
    - Menambahkan `webrtc.gain_control = true` untuk mencegah distorsi suara.
4.  **Status**: Menunggu konfirmasi user setelah menjalankan update script `fix-noise.sh`.

Perbaikan selesai dan suara terkonfirmasi jernih di berbagai aplikasi. File ini disimpan sebagai referensi akhir.
