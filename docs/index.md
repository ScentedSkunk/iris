<div id="top"></div>
  <p align="center">
    <img alt="CodeFactor Grade" src="https://img.shields.io/codefactor/grade/github/mschf-dev/iris?style=for-the-badge">
    <img alt ="Bash Version 4" src="https://img.shields.io/badge/BASH-4.0%2B-blueviolet?style=for-the-badge">
    <a href="https://github.com/mschf-dev/iris/blob/main/license"><img alt="GitHub license" src="https://img.shields.io/github/license/mschf-dev/iris?style=for-the-badge"></a>
    <a href="https://github.com/mschf-dev/iris/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/mschf-dev/iris?style=for-the-badge"></a>
    <img alt="GitHub code size in bytes" src="https://img.shields.io/github/languages/code-size/mschf-dev/iris?style=for-the-badge">
    <br />
  </p>
  <!-- HEADER -->
  <br />
  <div align="center">
  <p align="center">
    <a href="https://github.com/mschf-dev/iris/#gh-light-mode-only">
      <img src="/docs/img/logo_light.png"/>
    </a>
    <a href="https://github.com/mschf-dev/iris/#gh-dark-mode-only">
      <img src="/docs/img/logo_dark.png"/>
    </a>
  </p>

  <p align="center">
A minimal, customizable prompt for bash
    <br />
    <a href="https://github.com/mschf-dev/iris/issues">Report Bug</a>
    ·
    <a href="https://github.com/mschf-dev/iris/issues">Request Feature</a>
    <br />
    
  </p>
</div>
<!-- TABLE OF CONTENTS --> 
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-iris">About iris</a></li>
    <li><a href="#getting-started">Getting Started</a></li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#authors">Authors</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>

<!-- ABOUT -->
## 🧐 About iris

**A minimal, fast, and customizable prompt for BASH 4.0 or greater:**

**Minimal:** No excess bloat, straight and to the point.

**Customizable:** Configure settings for each user, one size does not always fit all.

**Hassle-free:** Easy to install, easy to update (if you so chose!)

<!-- GETTING  STARTED -->
## 🚀 Getting Started

### Prerequisites
  - sudo
  - git
  - wget (script install)
  
### Optional
 - [Nerd Fonts](https://www.nerdfonts.com/) - Simply enable in your terminal (We use [Hack Bold](https://www.nerdfonts.com/font-downloads))

### Installation

#### Install via script:
```bash
sudo su -
bash <(wget -qO - https://mschf.dev/iris)
```
#### Install via git:
```bash
sudo su -
git clone https://github.com/mschf-dev/iris "/opt/iris"
/opt/iris/src/tools/git-install.sh
```
<!-- USAGE -->
## 🎈 Usage 
- `--config [view|set] [var]`   
  - view or set configuration values in `~/.config/iris/iris.conf`
- `--defaults`
  - resets iris configuration to default
- `--disable-module [module]`
  - disables the provided module
- `--enable-module  [module]`
  - enables the provided module
- `--help`
  - displays iris help message
- `--modules`
  - lists all installed/available modules
- `--reload`
  - reloads iris configurations
- `--uninstall`
  - uninstalls iris
- `--upgrade`
  - upgrades iris to latest version
- `--version`
  - outputs installed iris version"

<!-- CONTRIBUTING -->
## 🤝 Contributing

Contributions are what make the world go around. We would love to be able to accept any new contributions, but I have not written the contribution guidelines yet.

<!-- LICENSE -->
## 📃 License

Distributed under the BSD-3-Clause License. See `license` for more information.

## ✍️ Authors
[@mschf2175](https://github.com/mschf2175) - Idea & Initial work

See the list of [contributors](https://github.com/mschf-dev/iris/contributors) who participated in this project.

<!-- ACKNOWLEDGEMENTS -->
## 📣 Acknowledgements
* [starship](https://github.com/starship/starship) - A customizable prompt built in rust.
* [nerd-fonts](https://github.com/ryanoasis/nerd-fonts) - Fonts patched with a high number of development related glyphs.
* [shields](https://github.com/badges/shields) - A service for concise, consistent badges.
* [codefactor](https://github.com/codefactor-io) - Automated code review for GitHub.
* [ohmybash](https://github.com/ohmybash/oh-my-bash) - An open source, community-driven framework for managing your bash configuration.
* [ohmyzsh](https://github.com/ohmyzsh/ohmyzsh) - A community-driven framework for managing your zsh configuration.

<p align="right">(<a href="#top">back to top</a>)</p>
