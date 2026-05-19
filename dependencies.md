## System dependencies

### fedora H.264 video codec

```bash
sudo dnf install \
https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf swap ffmpeg-free ffmpeg --allowerasing
sudo dnf install ffmpeg vlc mpv
``` 