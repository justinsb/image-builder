#!/bin/bash

set -e
set -x

cd ~

mkdir -p ~/bin/
cd ~/bin
ln -sf /usr/local/go/bin/go
ln -sf /usr/local/go/bin/gofmt

export PATH=~/bin:$PATH

mkdir -p ~/k8s/src/k8s.io
cd ~/k8s/src/k8s.io
git clone https://github.com/kubernetes/kops
cd kops
make
#bazel build -- //... -//vendor/...

mkdir -p ~/k8s/src/kope.io
cd ~/k8s/src/kope.io
git clone https://github.com/kopeio/etcd-manager

ln -sf ~/k8s/src/k8s.io/kops/bazel-bin/cmd/kops/linux_amd64_stripped/kops ~/bin/kops

mkdir -p ~/.config

ln -sf ~/.share/.aws ~/.aws
ln -sf ~/.share/.ssh ~/.ssh
ln -sf ~/.share/.gitconfig ~/.gitconfig
ln -sf ~/.share/.config/gh ~/.config/gh

cat > ~/.bash_aliases <<EOF
alias gst='git status'
alias k='kubectl'
EOF

cat > ~/.dconf.preload <<EOF
[org/mate/panel/general]
object-id-list=['window-list', 'workspace-switcher', 'object-0']
toplevel-id-list=['bottom']

[org/mate/panel/toplevels/bottom]
expand=true
orientation='bottom'
screen=0
y-bottom=0
size=24
y=1055

[org/mate/panel/objects/workspace-switcher]
applet-iid='WnckletFactory::WorkspaceSwitcherApplet'
locked=true
toplevel-id='bottom'
position=0
object-type='applet'
panel-right-stick=true

[org/mate/panel/objects/object-0]
applet-iid='BriskMenuFactory::BriskMenu'
toplevel-id='bottom'
position=0
object-type='applet'
panel-right-stick=false

[org/mate/panel/objects/window-list]
applet-iid='WnckletFactory::WindowListApplet'
locked=true
toplevel-id='bottom'
position=20
object-type='applet'

[org/mate/terminal/profiles/default]
background-color='#00002B2A3635'
use-theme-colors=false
palette='#2E2E34343636:#CCCC00000000:#4E4E9A9A0606:#C4C4A0A00000:#34346565A4A4:#757550507B7B:#060698209A9A:#D3D3D7D7CFCF:#555557575353:#EFEF29292929:#8A8AE2E23434:#FCFCE9E94F4F:#72729F9FCFCF:#ADAD7F7FA8A8:#3434E2'
bold-color='#000000000000'
foreground-color='#838294939695'
visible-name='Default'

[org/mate/desktop/background]
color-shading-type='solid'
primary-color='rgb(32,74,135)'
picture-options='wallpaper'
picture-filename=''
secondary-color='rgb(98,127,90)'

[org/mate/desktop/font-rendering]
dpi=96.0

[org/mate/marco/general]
theme='BlueMenta'

[org/mate/desktop/peripherals/mouse]
cursor-theme='mate-black'

[org/mate/desktop/interface]
window-scaling-factor=1
icon-theme='mate'
gtk-theme='BlueMenta'


EOF


cat <<EOF > ~/.xsession
#!/bin/bash

xrandr -s 1920x1080

export PATH=$PATH:~/bin
mkdir -p ~/.share
sudo mount -t 9p -o trans=virtio,version=9p2000.L share_dev .share/ || true

dconf load / < ~/.dconf.preload

code &
mate-terminal &
chromium &

mate-session
EOF
