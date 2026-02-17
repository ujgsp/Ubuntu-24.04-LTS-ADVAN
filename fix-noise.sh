#!/bin/bash

# 1. Set Mixer Levels (Hardware)
echo "Setting hardware mixer levels..."
amixer -c 0 sset 'Internal Mic Boost' 1
amixer -c 0 sset 'Capture' 80%

# 2. Create PipeWire Config Directory
echo "Creating PipeWire configuration directory..."
mkdir -p ~/.config/pipewire/pipewire.conf.d/

# 3. Create Noise Cancellation Config
echo "Creating permanent noise suppression config..."
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
        }
    }
}
]
EOF

echo "Done! Please restart your computer or run 'systemctl --user restart pipewire' to apply changes."
echo "Then, in SimpleScreenRecorder, select 'Clean Microphone' as your audio source."
