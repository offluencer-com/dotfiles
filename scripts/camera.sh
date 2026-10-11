#!/bin/sh
# Webcam in a bare window. Run again to close it.

DEVICE="${1:-/dev/video0}"
SIZE=320

if pkill -f 'wayland-app-id=webcam'; then
  exit 0
fi

exec mpv "av://v4l2:$DEVICE" \
  --wayland-app-id=webcam --title=webcam \
  --profile=low-latency --untimed --no-cache --no-audio \
  --demuxer-lavf-o=input_format=mjpeg,video_size=1280x720,framerate=30 \
  --vf=crop=ih*4/3:ih,hflip \
  --panscan=1.0 --autofit="$((SIZE*4/3))x${SIZE}" \
  --no-osc --no-osd-bar --osd-level=0 --no-border \
  --really-quiet
