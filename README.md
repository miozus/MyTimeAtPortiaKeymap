# MyTimeAtPortiaKeymap

Replace mouse operation, Simply repeat action.

One key does more than one thing.

![portiakeymap](docs/img/portiakeymap.png)

## Requirements

- OS : Windows 10 / 11
- Autohotkey : H-2.0-beta.3 ( @ [thqby/AutoHotkey_H](https://github.com/thqby/AutoHotkey_H.git) )
- My Time At Portia : final 2.0.141541 ( last updated time : 2021 / 08 )
- Game Resolution : `1680 * 1050` ( only )

## Install

1. download `.zip` package from lastest [Releases](https://github.com/miozus/MyTimeAtPortiaKeymap/releases/latest) and unzip . Or

``` bash
git clone https://github.com/miozus/MyTimeAtPortiaKeymap.git
```

2. open `Portia.ahk` with Notepad or Visual Studio Code, change setting as you like ( or use default setting of mine directly and skip this step )
   - GameSetting : write down what you set in game.
   - Keymap : `yourHotkey::function()` , you can define new function in `PortiaFuntions.ahk`
3. Setting In Game :
    - [x] Resolution must be `1680 * 1050` at window mode.
    - [x] Lens inertia must be checked, for move mouse with fluent perfomance.
3. open `Portia.ahk` with Autohotkey.exe ( win32 or x64w ) , run with **Administrator privilige** if hotkey not works in game. ( usually, normal privilige is OK ).
4. play game ( the order of launcher does not matter ).

## Usage

### 1 🏃‍♀️ Direction

Actor Move Direction:

| | Actor| | | | Mouse | |
|:----: | :----: | :----: | :----: | :----: | :----:| :---- |
|| <kbd>E</kbd>|||| <kbd>K</kbd>
|<kbd>S</kbd>|<kbd>D</kbd>|<kbd>F</kbd>| | <kbd>H</kbd> | <kbd>J</kbd> | <kbd>L</kbd>

Press <kbd>/</kbd> to resize actor's perspective to focus on forehead.

Hold on <kbd>A</kbd> while press mouse hotkey, to slow down mouse move speed, it performance well on bag UI.

Mouse :

| from| <kbd>I</kbd>|<kbd>O</kbd> | <kbd>;</kbd> | <kbd>'</kbd>
|:----: | :----: | :----:| :----: | :----: |
| to |LeftButton |RightButton|Scroll down | Scroll up |
| tips| ||ProductUI ⇒ *5 times | same

Turn Page:

Press <kbd>S</kbd> or <kbd>F</kbd> to turn page, When there are left or right button at Page UI. ( except BagUI case of poverty to release all grids )

Press <kbd>E</kbd> or <kbd>D</kbd> would depend on what `3 📦 Item Select` have done, to do previous or next action.

### 2 ⛏️ Work State

Each state has two skills, they aim to do one work together.

| State  | Name   | <kbd>T</kbd> Main      | <kbd>W</kbd> Assist | Tips                                                  |
| :----: | :----: | :----:                 | :-----:             | :----:                                                |
| 🛖     | Hoster | conitnueWorkingProduct | startMaxProduct     | default                                               |
| 🐟     | Fisher | fish +5                | fish -10            | number 1~5 ⇒ feed n*35 rice                           |
| ⛏️     | Farmer | LButtonClickLoop       | seekingTreasures    | Eletic Drill prefer to use mouse or hold <kbd>I</kbd> |

Press <kbd>.</kbd> to turn to next state for cycle.

### 3 📦 Item Selector

When different UI appears, it perfomance differently.

Default ( Outside )

| Hotkey                      | MapPosition | Tips      |
| :------                     | :------     | :------   |
| <kbd>1</kbd> ~ <kbd>8</kbd> | [1, 1-8]    | Equipment |

BagUI

| Hotkey                                              | MapPosition | Tips           |
| :------                                             | :------     | :------        |
| <kbd>1</kbd> ~ <kbd>8</kbd>                         | [1-8, 1]    | 1st row        |
| <kbd>9</kbd> <kbd>0</kbd> <kbd>-</kbd> <kbd>=</kbd> | [1-8, 2-5]  | the [2, 5] row |
| <kbd>P</kbd>                                        | [1-8, P]    | Equipment bar  |

ListUI

| Hotkey                      | MapPosition | Tips |
| :------                     | :------     | :------ |
| <kbd>1</kbd> ~ <kbd>8</kbd> | [1, 1-8]    | N's product       |

Specially, when you hold modifier key above all, it follow secondary action.

|Modifier       | Hotkey                      | MapPosition | Tips                                    |
|:----          | :------                     | :------     | :------                                 |
|<kbd>Ctrl</kbd>| <kbd>1</kbd> ~ <kbd>P</kbd> | [1-8, N]    | And Press Exchange ( to bag )           |
|<kbd>Alt</kbd> | <kbd>1</kbd> ~ <kbd>P</kbd> | [1-8, N]    | And Press RightButton ( to box / actor )|

### 4 🤖 Not Intelligent Robot

Perhaps it know what would you do next.

If you stay outside, farm or ride aircraft, it keep silent as origin key.

It appears at those scene:

- Accept the Chamber of Commerce Daily Quest
- Feed Animal
- Read Email
- Arrange food and wait for alpaca
- Dialog choose option 1
- Start challenge remains

It feels upset sometimes, keep patient please.

### 5 🧪 Devlop Tool

Now you have the ability to write code to recognise the game scene, and define new function.

| Combine                          |<kbd>G</kbd>                         | Tips                                           |
| :----:                           |:----:                               | :----:                                         |
| <kbd>Ctrl</kbd>                  | which scene now                     | detech every collected scene and register state|
| <kbd>Alt</kbd>                   | pixelsearch under cursor            | get copied code                                |
| <kbd>Ctrl</kbd> <kbd>Alt</kbd>   | click under cursor                  |get copied code                                 |
| <kbd>Ctrl</kbd> <kbd>Shift</kbd> | convert counterUI position to string|get copied code                                 |
| ( null )                         | <kbd>G</kbd>                        | press origin key                               |

Design notes will be release soon.

Game demo video is making.

## Contributing

All by myself, welcome to PR.

## License

MIT © Copyright (c) 2021 miozus
