#!/bin/bash

# 1. Set Mixer Levels (Hardware)
# Capture diturunkan ke 75% (+22.50dB) untuk mencegah suara pecah dan dengungan berlebih
echo "Menyetel level hardware mixer..."
amixer -c 0 sset 'Internal Mic Boost' 0
amixer -c 0 sset 'Capture' 75%

# 2. Membuat Direktori Konfigurasi PipeWire (jika belum ada)
echo "Memastikan direktori PipeWire ada..."
mkdir -p ~/.config/pipewire/pipewire.conf.d/

# 3. Membuat Konfigurasi Denoising yang Lebih Agresif
# Ditambahkan: High Pass Filter (menghapus dengungan rendah) dan Gain Control
echo "Memperbarui konfigurasi Clean Microphone (High-pass + Gain Control)..."
cat <<EOF > ~/.config/pipewire/pipewire.conf.d/99-input-denoising.conf
context.modules = [
{   name = libpipewire-module-echo-cancel
    args = {
        source.props = {
            node.name = "noised_source"
            node.description = "Clean Microphone"
        }
        aec.args = {
            "webrtc.noise_suppression" = true
            "webrtc.extended_filter" = true
            "webrtc.high_pass_filter" = true
            "webrtc.gain_control" = true
            "webrtc.typing_detection" = true
        }
    }
}
]
EOF

# 4. Restart PipeWire untuk menerapkan perubahan
echo "Menerapkan perubahan..."
systemctl --user restart pipewire

echo ""
echo "Selesai! Sekarang silakan lakukan hal berikut:"
echo "1. Di Discord (Settings > Voice & Video):"
echo "   - Pilih Input Device: 'Clean Microphone'"
echo "   - Matikan Noise Suppression (Krisp) jika suara masih aneh (agar tidak dobel)"
echo "2. Jika suara masih terlalu pelan, naikkan perlahan 'Capture' dengan perintah:"
echo "   amixer -c 0 sset 'Capture' 85%"
