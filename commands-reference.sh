# ╔══════════════════════════════════════════════════════════════════════╗
# ║  PHANTOM RICE — Command Reference & Cheatsheet                      ║
# ║  Arch Linux · MacBook Pro A1706 · All the tools you need             ║
# ╚══════════════════════════════════════════════════════════════════════╝

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  PACMAN & SYSTEM
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Package Management
sudo pacman -Syu                           # Full system upgrade
sudo pacman -S <pkg>                       # Install package
sudo pacman -Rs <pkg>                      # Remove pkg + unused deps
sudo pacman -Ss <query>                    # Search repos
sudo pacman -Qs <query>                    # Search installed
sudo pacman -Qi <pkg>                      # Info about installed pkg
sudo pacman -Ql <pkg>                      # List files of pkg
pacman -Qe                                 # List explicitly installed
pacman -Qdt                                # List orphans
sudo pacman -Rns $(pacman -Qdtq)           # Remove all orphans
paru -S <pkg>                              # Install from AUR
paru -Sua                                  # Update AUR packages
paru -Ss <query>                           # Search AUR + repos

# Mirrors
sudo reflector --country US,CA --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Disk usage by package
expac -HM '%m\t%n' | sort -n | tail -30

# System services
systemctl status <service>                 # Check service status
systemctl enable --now <service>           # Enable + start service
systemctl restart <service>                # Restart service
journalctl -xeu <service>                  # View service logs
journalctl -b -p err                       # View boot errors

# System info
uname -r                                   # Kernel version
lscpu                                      # CPU info
lsblk                                      # Block devices
lspci                                      # PCI devices
lsusb                                      # USB devices
free -h                                    # Memory usage
df -h                                      # Disk usage

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  DOCKER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

docker ps                                  # Running containers
docker ps -a                               # All containers
docker images                              # List images
docker build -t <name> .                   # Build image
docker run -d --name <n> <img>             # Run detached
docker run -it <img> /bin/bash             # Run interactive
docker exec -it <container> /bin/bash      # Exec into container
docker logs -f <container>                 # Follow logs
docker stop $(docker ps -q)                # Stop all containers
docker rm $(docker ps -aq)                 # Remove all containers
docker rmi $(docker images -q)             # Remove all images
docker system prune -af                    # Nuclear cleanup
docker volume ls                           # List volumes
docker network ls                          # List networks
docker stats                               # Live resource usage

# Docker Compose
docker compose up -d                       # Start services
docker compose down                        # Stop services
docker compose logs -f                     # Follow all logs
docker compose build --no-cache            # Rebuild
docker compose ps                          # Service status
docker compose exec <svc> bash             # Exec into service

# lazydocker                               # TUI Docker manager (alias: lzd)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  KUBERNETES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

kubectl get pods                           # List pods (alias: kgp)
kubectl get svc                            # List services (alias: kgs)
kubectl get deployments                    # List deployments (alias: kgd)
kubectl get all                            # List everything
kubectl get nodes                          # List nodes
kubectl describe pod <name>                # Pod details
kubectl logs -f <pod>                      # Follow pod logs
kubectl exec -it <pod> -- /bin/bash        # Exec into pod
kubectl apply -f <file.yaml>               # Apply manifest
kubectl delete -f <file.yaml>              # Delete from manifest
kubectl scale deploy <name> --replicas=3   # Scale deployment
kubectl rollout restart deploy <name>      # Rolling restart
kubectl config get-contexts                # List contexts
kubectl config use-context <ctx>           # Switch context (alias: ctx)
kubectl config set-context --current --namespace=<ns>  # Set namespace (alias: ns)
kubectl top pods                           # Pod resource usage
kubectl top nodes                          # Node resource usage

# k9s                                      # TUI K8s dashboard (alias: k9)

# Helm
helm repo add <name> <url>                 # Add chart repo
helm install <release> <chart>             # Install chart
helm upgrade <release> <chart>             # Upgrade release
helm list                                  # List releases
helm uninstall <release>                   # Remove release

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  SSH & REMOTE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ssh <user>@<host>                          # Connect
ssh -i <key> <user>@<host>                 # Connect with specific key
ssh -L 8080:localhost:80 <host>            # Local port forward
ssh -R 8080:localhost:80 <host>            # Remote port forward
ssh -D 1080 <host>                         # SOCKS proxy
ssh -J <jumphost> <target>                 # Jump/bastion host
scp <file> <user>@<host>:<path>            # Copy file to remote
scp <user>@<host>:<path> <local>           # Copy file from remote
rsync -avz <src> <user>@<host>:<dst>       # Sync files (fast)
rsync -avz --delete <src> <dst>            # Sync + delete extras
mosh <user>@<host>                         # Mobile shell (survives drops)
sshfs <user>@<host>:<path> <mount>         # Mount remote filesystem

# SSH key management
ssh-keygen -t ed25519 -C "email@x.com"    # Generate modern key
ssh-copy-id <user>@<host>                  # Copy key to server
ssh-add ~/.ssh/<key>                       # Add key to agent
ssh-add -l                                 # List loaded keys

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  TMUX / ZELLIJ (Terminal Multiplexers)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Tmux
tmux                                       # New session
tmux new -s <name>                         # Named session
tmux ls                                    # List sessions
tmux a -t <name>                           # Attach to session
tmux kill-session -t <name>                # Kill session
# Inside tmux: Ctrl+B then...
#   c = new window     n = next window    p = prev window
#   " = split horiz    % = split vert     d = detach
#   z = zoom pane      x = close pane

# Zellij
zellij                                     # Start
zellij -s <name>                           # Named session
zellij ls                                  # List sessions
zellij a <name>                            # Attach
# Inside: Ctrl+P (pane), Ctrl+T (tab), Ctrl+N (resize)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  DATABASE CLIENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# PostgreSQL (pgcli — alias: pg)
pgcli -h <host> -p 5432 -U <user> -d <db>
pgcli postgresql://<user>:<pass>@<host>/<db>

# MySQL (mycli — alias: my)
mycli -h <host> -u <user> -p <pass> <db>
mycli mysql://<user>:<pass>@<host>/<db>

# Redis
redis-cli -h <host> -p 6379
redis-cli -u redis://<host>:<port>

# MongoDB
mongosh "mongodb://<host>:27017/<db>"

# SQLite
sqlite3 <file.db>

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  PYTHON & AI/ML
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Virtual environments
python3 -m venv .venv                      # Create venv (alias: venv)
source .venv/bin/activate                  # Activate (alias: activate)
deactivate                                 # Deactivate

# pyenv
pyenv install --list                       # Available versions
pyenv install 3.12.0                       # Install version
pyenv global 3.12.0                        # Set global version
pyenv local 3.12.0                         # Set project version
pyenv versions                             # List installed

# Mamba/Conda
mamba create -n <name> python=3.12         # Create env
mamba activate <name>                      # Activate
mamba deactivate                           # Deactivate
mamba install <pkg>                        # Install package
mamba env list                             # List envs
mamba env export > env.yml                 # Export env
mamba env create -f env.yml                # Create from file

# uv (Astral — fast pip replacement)
uv pip install <pkg>                       # Install
uv pip compile requirements.in             # Lock deps
uv pip sync requirements.txt               # Sync deps
uv venv                                    # Create venv
uv run <script.py>                         # Run with auto-env

# Jupyter
jupyter lab                                # Launch (alias: jup)
jupyter lab --no-browser --port=8888       # Headless

# ML Remote monitoring
ssh ml-server 'nvidia-smi'                 # Check GPU
ssh ml-server 'nvidia-smi -l 2'            # Watch GPU loop
ssh ml-server 'watch -n 2 nvidia-smi'      # Live monitor (alias: ml-watch)
ssh ml-server 'tail -f ~/training/logs/latest.log'  # Training log (alias: ml-logs)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  AI CHAT TOOLS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Ollama (local LLM)
ollama pull llama3                         # Download model
ollama run llama3                          # Chat with model
ollama list                                # List models
ollama serve                               # Start API server
ollama rm <model>                          # Remove model

# aichat (multi-provider CLI — alias: ai)
aichat                                     # Interactive mode
aichat -m claude "your prompt"             # Single query
aichat --list-models                       # Available models
echo "code" | aichat "explain this"        # Pipe input

# tgpt (no-API-key chat — alias: ask)
tgpt "your question"                       # Quick query
tgpt -i                                    # Interactive mode

# Claude Code CLI (alias: claude in npm)
claude                                     # Start session

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  GIT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

git status -sb                             # Short status (alias: gs)
git add -p                                 # Interactive stage
git commit -m "msg"                        # Commit (alias: gcm)
git push                                   # Push (alias: gp)
git pull --rebase                          # Pull with rebase (alias: gl)
git diff --staged                          # Staged changes (alias: gds)
git log --oneline --graph --decorate -20   # Pretty log (alias: glog)
git stash                                  # Stash changes
git stash pop                              # Apply stash
git rebase -i HEAD~3                       # Interactive rebase
git cherry-pick <hash>                     # Cherry pick
git bisect start                           # Binary search for bug
git reflog                                 # Recovery tool
git blame <file>                           # Line-by-line history
lazygit                                    # TUI git manager (alias: lg)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  TERRAFORM & ANSIBLE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Terraform
terraform init                             # Initialize
terraform plan                             # Preview changes
terraform apply                            # Apply changes
terraform destroy                          # Destroy infra
terraform state list                       # List resources
terraform output                           # Show outputs
terraform fmt                              # Format files
terraform validate                         # Validate syntax

# Ansible
ansible-playbook <playbook.yml>            # Run playbook
ansible-playbook -i <inventory> <play.yml> # With inventory
ansible all -m ping                        # Ping all hosts
ansible all -m shell -a "uptime"           # Run command
ansible-vault encrypt <file>               # Encrypt file
ansible-vault decrypt <file>               # Decrypt file

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  NETWORKING & SECURITY
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ip addr                                    # Network interfaces
ip route                                   # Routing table
ss -tulnp                                  # Listening ports (alias: ports)
curl -s ifconfig.me                        # Public IP (alias: myip)
nmap -sV <host>                            # Port scan + versions
nmap -sn 192.168.1.0/24                    # Network discovery
dog <domain>                               # DNS lookup (alias: dig)
dog <domain> MX                            # MX records
traceroute <host>                          # Trace route
mtr <host>                                 # Better traceroute
bandwhich                                  # Live bandwidth monitor
curl -I <url>                              # HTTP headers only
httpie GET <url>                           # Pretty HTTP client

# Firewall (nftables)
sudo nft list ruleset                      # Show rules
sudo systemctl status nftables             # Status

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  MODERN CLI TOOLS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# File listing (eza — replaces ls)
eza --icons                                # alias: ls
eza -la --icons --git                      # alias: ll
eza -laT --level=2                         # alias: lt (tree)

# File preview (bat — replaces cat)
bat <file>                                 # alias: cat
bat -l json <file>                         # Force language
bat --diff <file>                          # Show git diff

# Search (ripgrep — replaces grep)
rg "pattern"                               # alias: grep
rg "pattern" -t py                         # Only Python files
rg "pattern" -g "*.js"                     # Glob filter
rg -i "pattern"                            # Case insensitive

# Find (fd — replaces find)
fd "pattern"                               # alias: find
fd -e py                                   # By extension
fd -t d "pattern"                          # Directories only

# Jump (zoxide — replaces cd)
cd <partial-name>                          # Smart jump (via zoxide)
cd -                                       # Previous dir

# Fuzzy finder (fzf)
fzf                                        # Interactive filter
Ctrl+T                                     # Insert file path
Ctrl+R                                     # Search history
Alt+C                                      # Jump to dir

# JSON (jq)
jq '.' <file.json>                         # Pretty print
jq '.key' <file.json>                      # Extract key
curl <url> | jq '.'                        # Format API response

# Disk usage (dust — replaces du)
dust                                       # alias: du
dust -r                                    # Reverse sort

# Disk free (duf — replaces df)
duf                                        # alias: df

# Process viewer (procs — replaces ps)
procs                                      # alias: ps
procs <name>                               # Filter by name

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  HYPRLAND (Window Manager)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Keybindings
# SUPER + Return         → Terminal (Kitty)
# SUPER + D              → App launcher (Rofi)
# SUPER + Q              → Kill window
# SUPER + V              → Toggle float
# SUPER + F              → Fullscreen
# SUPER + L              → Lock screen
# SUPER + E              → File manager
# SUPER + S              → Screenshot (region)
# SUPER + Tab            → Window switcher
# SUPER + 1-9            → Workspace
# SUPER + SHIFT + 1-9    → Move to workspace
# SUPER + arrows/HJKL    → Focus direction
# SUPER + SHIFT + arrows → Move window
# SUPER + CTRL + arrows  → Resize window
# 3-finger swipe         → Workspace switch

# hyprctl
hyprctl monitors                           # Monitor info
hyprctl clients                            # Window list
hyprctl activewindow                       # Current window
hyprctl dispatch exec kitty                # Run command
hyprctl reload                             # Reload config
hyprctl keyword general:border_size 2      # Runtime config

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  MONITORING TOOLS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

btop                                       # System monitor (alias: top)
nvtop                                      # GPU monitor
ttop                                       # Lightweight TUI top
intel_gpu_top                              # Intel GPU monitor
htop                                       # Classic process viewer
powertop                                   # Power usage
bandwhich                                  # Network bandwidth
iotop                                      # Disk I/O monitor

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  MACBOOK A1706 SPECIFIC
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Display brightness
brightnessctl set 50%                      # Set brightness
brightnessctl set 5%+                      # Increase
brightnessctl set 5%-                      # Decrease

# Wi-Fi (Broadcom)
nmcli device wifi list                     # Scan networks
nmcli device wifi connect <SSID> password <pass>  # Connect
nmcli connection show                      # List connections
nmtui                                      # TUI network manager

# Battery
cat /sys/class/power_supply/BAT0/capacity  # Battery %
tlp-stat -b                               # Battery health
powertop --html=report.html                # Power report

# Touch Bar
systemctl status tiny-dfr                  # Touch Bar status
