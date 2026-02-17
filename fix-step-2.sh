#!/bin/bash

# 1. Buat file firmware patch untuk mematikan deteksi jack (Phantom Jack)
echo "[codec]
0x10ec0269 0x1e507007 0

[pincfg]
0x18 0x04a19130
0x21 0x04211120" > hda-advan.fw

echo "File hda-advan.fw telah dibuat."

# 2. Instruksi untuk user
echo "-------------------------------------------------------"
echo "Langkah selanjutnya (Jalankan secara manual):"
echo "1. Pindahkan file firmware ke folder sistem:"
echo "   sudo mv hda-advan.fw /lib/firmware/"
echo ""
echo "2. Edit konfigurasi alsa-base.conf:"
echo "   sudo nano /etc/modprobe.d/alsa-base.conf"
echo ""
echo "   Ubah barisnya menjadi:"
echo "   options snd-hda-intel model=laptop-amic patch=hda-advan.fw"
echo ""
echo "3. Reboot sistem:"
echo "   sudo reboot"
echo "-------------------------------------------------------"
