# MyTimeAtPortiaKeymap

Replace mouse operation, Simply repeat action.

## Requirements

- OS : Windows 10 / 11
- Autohotkey : H-2.0-beta.3 ( @ [thqby/AutoHotkey_H](https://github.com/thqby/AutoHotkey_H.git) , or download from my release which complied yet)
- My Time At Portia Version : final 2.0.141541 (last updated time : 2021 / 08)
- Game Resolution : `1680 * 1050` (only)

## Install

1. download `.zip` package from lastest [Releases](https://github.com/miozus/MyTimeAtPortiaKeymap/releases/latest)    and unzip

Or

``` bash
git clone https://github.com/miozus/MyTimeAtPortiaKeymap.git
```

2. open `Portia.ahk` with Notepad or Visual Studio Code, change setting as you like (or use default as mine directly)
   - GameSetting : write down what you set in game.
   - Keymap : `yourHotkey::function()` , you can define new function in `PortiaFuntions.ahk`
   - In Game :
     - [x] Resolution must be `1680 * 1050` at window mode
     - [x] Lens inertia must be checked, for scene move with fluent perfomance
4. open `Portia.ahk` with Autohotkey.exe ( win32 or x64w )
5. run Game and play

## Usage

keyboard maping:

![portiakeymap](docs/img/portiakeymap.png)

design notes will be release soon.

Game demo video is making.

## Contributing

All by myself, welcome to PR.

## License

MIT © Copyright (c) 2021 miozus
