
<div align="center">

# ✦ nucleus-shell ✦

<p align="center">
  <img src="https://img.shields.io/github/last-commit/nucleus-hq/nucleus-shell?style=for-the-badge&color=8b5cf6&logo=git&logoColor=EDE9FE&labelColor=1E1B2E" />
  &nbsp;&nbsp;
  <img src="https://img.shields.io/github/stars/nucleus-hq/nucleus-shell?style=for-the-badge&logo=andela&color=8b5cf6&logoColor=EDE9FE&labelColor=1E1B2E" />
  &nbsp;&nbsp;
  <img src="https://img.shields.io/github/repo-size/nucleus-hq/nucleus-shell?style=for-the-badge&color=8b5cf6&logo=protondrive&logoColor=EDE9FE&labelColor=1E1B2E" />
  &nbsp;&nbsp;
  <img src="https://img.shields.io/badge/Maintenance-Active-8b5cf6?style=for-the-badge&logo=vercel&logoColor=EDE9FE&labelColor=1E1B2E" />
</p>

</div>

---
<h2 align="center">✦ Overview ✦ </h2>

#### A shell built to get things done.

Key goals:
- Prefer Usability
- Composable modules, design and appearance

> [!IMPORTANT]
> * If you want to access the older releases refer to the [archive branch](https://github.com/nucleus-hq/nucleus-shell/tree/archive)
> * You can also join the [discord server](https://discord.gg/FcvT2VabEM) for help.
> * **Before reporting an issue:**
  If you encounter a problem in the current release, please first test against the latest source code by cloning the repository (`git clone ...`). This ensures you are not reporting an issue that has already been fixed.
  Only open an issue if the problem is still reproducible on the latest source.

> [!CAUTION]
> * You will find a lot of design and ui inconsistencies with the latest git clone because it is under development. Prefer using the latest release rather than the latest clone.


---

<h2 align="center">✦ Previews ✦</h2>


<div align="center">

| Built with love                                  | Forests                                            |
|--------------------------------------------------|----------------------------------------------------|
| ![](/previews/Love.png)                          | ![](/previews/Forests.png)                         |
| **Passion**                                      | **Metallic**                                       |
| ![](/previews/Passion.png)                       | ![](/previews/Metallic.png)                        |

</div>

---

<h2 align="center">✦ Related Projects ✦</h2>

* [nucleus-cli](https://github.com/nucleus-hq/nucleus-cli): CLI for nucleus-shell
* [nucleus-plugins](https://github.com/nucleus-hq/nucleus-plugins): Plugins for nucleus-shell
* [nucleus-colorschemes](https://github.com/nucleus-hq/nucleus-colorschemes): Colorschemes for nucleus-shell
* [zenith](https://github.com/xZepyx/zenith): Intelligence backend for nucleus-shell (required to use intelligence)

> [!CAUTION]
> Note that any other repositories related to this project are community-made. Do not use them.

---

<h2 align="center">✦ Repository layout ✦</h2>


- /quickshell/     — Primary shell
- /license/        — License and contributing docs
- /previews/       — Example screenshots used in this README
- /install/          — Installer scripts and bootstrap utilities
- /.github/        — README and other stuff

---

<h2 align="center">✦ Installation ✦</h2>


Follow these steps to install the shell. The automated setup is conservative and will prompt before making destructive changes.

### Using the cli
```
yay -S nucleus-shell
nucleus install
```

### Using the install script
```bash
git clone https://github.com/nucleus-hq/nucleus-shell
cd nucleus-shell/install
./unified.sh
```
Notes:
- Manual installation (symlinking files yourself) is supported and recommended for cautious users.
- Install Script is preffered over the cli installation. 
- Back up your existing dotfiles (e.g. ~/.config/ ~/.bashrc, ~/.zshrc, ~/.profile) before running the bootstrap.

---

<h2 align="center">✦ Configuration &amp; customization ✦</h2>

- Primary config: `~/.config/nucleus-shell/config/configuration.json`
- Modular settings: prompt, completion, and widget modules are separated for easy replacement.
- To customize:
  - Edit the primary config or use the provided settings app.
  - Enable/disable modules by editing the module list in the `~/.config/quickshell/nucleus-shell/shell.qml` file.

---

<h2 align="center">✦ Recommended environment ✦</h2>

- Compositor: Hyprland
- Terminal: Kitty
- Fonts: JetBrainsMono

---

<h2 align="center">✦ Troubleshooting ✦</h2>

- Missing/Unloaded Modules:
  - Ensure the module file is loaded in the correct order. Check `~/.config/quickshell/nucleus-shell/shell.qml`.
- Broken visuals:
  - Check `~/.local/share/nucleus/user/config.json`
- Slow startup:
  - Disable unused modules or lazy-load heavy features (e.g., prompt segments that query network/state).
- Conflicting user configs:
  - Inspect existing profile files (`~/.bashrc`, `~.zshrc`, `~/.profile`, `~/.config`) before applying changes.
- Installer failures:
  - Re-run the installer with verbose output or check `install/` scripts for dependency checks.
- Cli Commands
  - To update: `nucleus update` The cli will guide you through the update.
  - To uninstall: `nucleus uninstall` The cli will automaticly uninstall the shell.
  - To stop/kill the shell: `nucleus kill` or `nucleus stop`
  - To switch themes: `nucleus switch theme <themename>`
  - More at: [cli-documentation](https://github.com/nucleus-hq/nucleus-cli)
 
---

<h2 align="center">✦ To-Do ✦</h2>

- Read [Todo.md](../docs/Todo.md)

---
<div align="center">
  
## ✦ Weird Tentacles ✦
<a href="https://www.star-history.com/#nucleus-hq/nucleus-shell&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=nucleus-hq/nucleus-shell&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=nucleus-hq/nucleus-shell&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=nucleus-hq/nucleus-shell&type=date&legend=top-left" />
 </picture>
</a>

</div>

---

<h2 align="center">✦ Contributing ✦</h2>

Contributions are welcome. When contributing:
- Open concise issues after confirming the problem isn't caused by local configuration.
- Submit focused PRs with clear descriptions and tests where applicable.
- Follow code structure and naming conventions used in the codebase.

- See [CONTRIBUTING.md](CONTRIBUTING.md) for full contribution guidelines.

---

<h2 align="center">✦ Maintainer ✦</h2>

- Maintainer: xZepyx 
- Contact: [zepyxunderscore@gmail.com](mailto:zepyxunderscore@gmail.com)

---

<h2 align="center">✦ Acknowledgments ✦</h2>

- QuickShell and its contributors
- Hyprland and its developers/contributors

---

<h2 align="center">✦ Inspiration / Copying ✦</h2>

#### I did copy some code from other repositories and took design inspirations which are listed here:
* [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) (Copied some services, took some design inspirations)
* [etherealboi/twinshell](https://github.com/etherealboi/twinshell) (Some widgets)
* [bgibson72/yahr-quickshell](https://github.com/bgibson72/yahr-quickshell) (A script that lists installed apps)
* [caelestia-dots/shell](https://github.com/caelestia-dots/shell) (Didn't copy any code, but yoinked a lot of design from caelestia's vertical bar design)

---

<h2 align="center">✦ Thank You ✦</h2>

* [@ivan](https://github.com/SavingFrame): Thanks bro for being our first contributor. :P
* [@Tanujairamv](https://github.com/Tanujairamv): For being a great friend and contributing to the project and the community. <3
* [@Saturno](https://github.com/Saturno-0): For being a great friend and contributing to the project and the community. ;)
* [@end4](https://github.com/end4): For his great projects like ii-qs.
* [@soramanew](https://github.com/soramanew): We haven't talked but I was greatly inspired by his project **caelestia-shell**.
* [@Axenide](https://github.com/axenide): I also haven't talked to him but his project **Ax-Shell** got me into hyprland shells.

---

<h2 align="center">✦ Team/Project Members ✦</h2>

* [@xZepyx](https://github.com/xZepyx): Founder & Maintainer
* [@TanujairamV](https://github.com/TanujairamV): Material UI Developer & Designer
* [@Saturno](https://github.com/Saturno-0): Logical Developer

---

<h2 align="center">✦ Fella Contributors ✦</h2>

<div align="center">
  <img src="https://contrib.rocks/image?repo=xZepyx/nucleus-shell" alt="Contributors"/>
</div>

---

<h2 align="center">✦ License ✦</h2>

© 2025-PRESENT xZepyx — Licensed under the GNU GPL v3

---


