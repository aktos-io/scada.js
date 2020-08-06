# Preparing development environment on Windows 

> Tested on Win7

1. Download and install MSYS2.

2. In MSYS2 console: 

        pacman -Syu
        pacman -S make git python python-pip tmux

3. Use any command in the MSYS2 command prompt.

4. PATCH nodeenv: https://github.com/ekalinin/nodeenv/pull/263

5. Optional: Apply MSYS2 "Open Here" settings (execute `msys2-here.reg`). 



