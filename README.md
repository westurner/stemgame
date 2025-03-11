# stemgame

# Tools for Roblox Development

## roblox
- src: https://github.com/roblox
- docs: https://github.com/Roblox/creator-docs

Roblox is a partially open-source MMORPG with a scripting engine
and the [Roblox Studio](#roblox-studio) IDE built with the [Luau](#luau) fork of Lua 5.1+.

## roblox studio
- docs: https://create.roblox.com/docs/studio
- download: https://create.roblox.com/docs/studio/setup

Roblox Studio is the official IDE for Roblox development.

- Roblox Studio includes a level editor, a [luau](#luau) script editor with autocomplete,
  a local emulator, an AI assistant, and collaborative features.
- How to save a Place created in Roblox Studio:
  - File > Save to Roblox (as) (as the logged-in user)
  - File > Download a Copy -- save to a local file in `.rbxl` or `.rbxlx` format with "Download File"
  - File > Publish to Roblox (as) -- publish a game to Roblox so that others can see it
  - Ribbon > Home > Settings > Game Settings > Permissions: (Friends || Public || Private)
- Roblox Studio camera control keyboard shortcuts:
  https://create.roblox.com/docs/studio/ui-overview#camera-controls :
  - WASD : Forward, Left, Back, Right
  - QE : Up, Down
  - F : Focus part selected in object Explorer
  - Scroll : Zoom
  - Right Click + Drag: Move the camera view
    - Right Click + Drag *on a multitouch touchpad*:
      - Tap or Press with both fingers and then Drag with either or both fingers
  - Middle Click + Drag: Pan the camera view
- Roblox Studio keyboard shortcuts:
  - Alt-X: toggle Explorer open/closed
  - [ ] toggle Properties open/closed
  - F11: toggle Full-screen
  - F12: record a videos
  - PrintScreen: take a screenshot (MacOS: Command-Shift-3)

### vinegar
- src: https://github.com/vinegarhq/vinegar
- docs: https://vinegarhq.org/

Vinegar is an open source flatpak package which installs WINE and Roblox Studio,
with a GUI for restarting Roblox Studio, configuring Vinegar, and configuring WINE.

- WINE: WINE is not an Emulator
  - WINE runs Windows apps on Linux, MacOS, and BSD
- DXVK: Direct3D 8/9/10/11 implemented with the Vulcan linux graphics subsystem

## roblox performance

- /? fastest way to do continuous collision in roblox: 
  https://www.google.com/search?q=fastest+way+to+do+continuous+collision+in+roblox
  - raycasting
    - raycast first; find the intersection between the ray and the target position
      and move to the outer hull of the target object
      to prevent collisions and/or clipping artifacts



## luau
- web: https://luau.org/
- src: https://github.com/luau-lang/luau
- docs: https://luau.org/syntax
- docs: https://luau.org/compatibility
- docs: https://luau.org/performance
- docs: https://luau.org/library
- LearnXinYMinutes > Lua: https://learnxinyminutes.com/lua/
  
Luau is an open source fork of Lua 5.1 for Roblox.

- [lune](#lune) is a script runtime for running `.lua` scripts with luau. 

Luau standard library:

- https://luau.org/library#global-functions
- https://luau.org/library#math-library
- https://luau.org/library#table-library
- https://luau.org/library#string-library
- https://luau.org/library#coroutine-library
- https://luau.org/library#bit32-library
- https://luau.org/library#utf8-library
- https://luau.org/library#os-library
- https://luau.org/library#debug-library
- https://luau.org/library#buffer-library
- https://luau.org/library#vector-library


## lune
- src: https://github.com/lune-org/lune
- docs: https://lune-org.github.io/docs/
- docs: https://lune-org.github.io/docs/getting-started/1-installation
- docs: https://lune-org.github.io/docs/roblox/1-introduction
- docs: https://lune-org.github.io/docs/roblox/2-examples
- docs: https://lune-org.github.io/docs/roblox/4-api-status

.

- Lune is a [luau](#luau) script runtime for running .lua scripts with luau lua as in Roblox.
- Lune includes libraries to decode and encode `.rbxl` and `.rbxlx` files.
- Lune includes libraries to select Roblox objects from `.rbxl` and `.rbxlx` files
  - rbx-dom is a library for interacting with Roblox object instances 



## Package Managers for roblox dev

### TOML
- wikipedia: https://en.wikipedia.org/wiki/TOML
- web: https://toml.io/en/
- src: https://github.com/toml-lang/toml
- docs: https://toml.io/en/v1.0.0


### cargo
- wikipedia: https://en.wikipedia.org/wiki/Rust_(programming_language)#Cargo
- src: https://github.com/rust-lang/cargo
- docs: https://doc.rust-lang.org/cargo/
- docs: https://doc.rust-lang.org/cargo/reference/semver.html
- configfile: Cargo.toml

Cargo is a rust-lang package manager.

- Cargo.toml is the cargo build configuration file; which is in [TOML](#toml) format.
- Aftman, wally, lune, rojo are built with Cargo and can be installed with Cargo
  (TODO and the tools installed in the devcontainer Dockerfile)
- Cargo installs from [crates.io](#cratesio), git, GitHub, the local filesystem

#### crates.io
- web: https://crates.io/
- src: https://github.com/rust-lang/crates.io/

crates.io is the rust-lang package index.

##### cargo binstall
- src: https://github.com/cargo-bins/cargo-binstall

> Binstall works by fetching the crate information from crates.io and searching the linked repository for matching releases and artifacts, falling back to the quickinstall third-party artifact host, to alternate targets as supported, and finally to `cargo install` as a last resort.


### aftman
- src: https://github.com/LPGhatguy/aftman
- docs: https://github.com/LPGhatguy/aftman#getting-started
- cargopkg: aftman
- configfile: aftman.toml

Aftman is a toolchain manager for Roblox development.

- Aftman installs releases from GitHub:  
  https://github.com/LPGhatguy/aftman/blob/main/src/tool_source/github.rs


### wally
- src: https://github.com/UpliftGames/wally
- docs: https://wally.run/
- download: https://github.com/UpliftGames/wally/releases
- cargopkg: wally
- configfile: wally.toml

Wally is a package manager for Roblox luau projects.

- Wally installs packages from [wally-index](#wally-index).


#### wally-index
- src: https://github.com/UpliftGames/wally-index
- src: https://github.com/UpliftGames/wally-index/tree/main/jsdotlua

wally-index is a package index of wally packages for roblox development with luau.


## rojo
- src: https://github.com/rojo-rbx/rojo
- docs: https://rojo.space/docs/
- vscode plugin: https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo
- Rojo Roblox Plugin: https://create.roblox.com/store/asset/4048317704/Rojo-6
- cargopkg: rojo

> Generated by [Rojo](https://github.com/rojo-rbx/rojo) 7.4.4.

> ### Getting Started
> To build the place from scratch, use:
>
> ```bash
> rojo build -o "stemgame.rbxlx"
> ```
>
> Next, open `stemgame.rbxlx` in Roblox Studio and start the Rojo server:
>
> ```bash
> rojo serve
> ```
>
> For more help, check out [the Rojo documentation](https://rojo.space/docs).


## rbx-dom
- src: https://github.com/rojo-rbx/rbx-dom


## Patterns for roblox dev
- ~= JS `addEventHandler`
  - TODO
- React, Redux, React-Navigation
  - There are ports of JS/TS libraries to lua
    - [react-lua](#react-lua)
    - [rodux](#rodux)
    - [roact-redux](#roact-redux)
    - [roact-navigation](#roact-navigation)
    - [jest-react](#jest-react)
    - [jest-lua](#jest-lua)

.

- Transpile TypeScript to [luau](#luau) with [roblox-ts](#roblox-ts).
- Transpile Python to [luau](#luau)


### react and redux patterns
- react: only setState(...) mutates the state table
- redux: there's a stack of app state history tables,
  so that the `back` button works


### react-lua
- src: https://github.com/Roblox/react-lua
- src: https://github.com/jsdotlua/react-lua
- docs: https://react.dev/learn
- docs: https://roblox.github.io/roact-alignment/
- docs: https://roblox.github.io/roact-alignment/deviations/
- docs: https://github.com/jsdotlua/react-lua/blob/main/DEVIATIONS.md
- docs: https://roblox.github.io/roact-alignment/api-reference/react/
- docs: https://reactjs.org/docs/getting-started.html
- docs: https://reactjs.org/docs/getting-started.html
- docs: https://react.dev/learn/passing-props-to-a-component
- docs: https://react.dev/learn/managing-state
- docs: https://react.dev/learn/sharing-state-between-components
- docs: https://react.dev/learn/keeping-components-pure#side-effects-unintended-consequences
- docs: https://react.dev/learn/understanding-your-ui-as-a-tree#the-render-tree
- docs: https://react.dev/learn/escape-hatches#referencing-values-with-refs
- docs: https://roblox.github.io/roact-alignment/deviations/#bindings-and-refs
- docs: https://roblox.github.io/roact-alignment/configuration/#__dev__
- docs: https://roblox.github.io/roact-alignment/api-reference/react/#reactcreateelement
- docs: https://react.dev/reference/react
- docs: https://react.dev/reference/react/createElement#creating-an-element-without-jsx

### rodux
- src: https://github.com/Roblox/rodux
- docs: https://roblox.github.io/rodux
- docs: https://roblox.github.io/rodux/introduction/store/
- docs: https://roblox.github.io/rodux/introduction/actions/
- docs: https://roblox.github.io/rodux/introduction/reducers/
- docs: https://roblox.github.io/rodux/example/
- docs: https://redux.js.org/tutorials/essentials/part-1-overview-concepts
- docs: https://redux.js.org/tutorials/fundamentals/part-1-overview

### cryo
- src: https://github.com/jsdotlua/cryo

### roact-redux
- src: https://github.com/Roblox/roact-rodux
- docs: https://roblox.github.io/roact-rodux/guide/usage/
- docs: https://roblox.github.io/roact-rodux/guide/usage/#add-a-storeprovider
- docs: https://roblox.github.io/roact-rodux/guide/usage/#connect-with-connect
- docs: https://roblox.github.io/roact-rodux/api-reference/

### roact-navigation
- src: https://github.com/Roblox/roact-navigation
- src: https://github.com/jsdotlua/roact-navigation
  -    https://github.com/Roblox/roact-navigation/compare/master...jsdotlua:roact-navigation:master
- docs: https://github.com/Roblox/roact-navigation/blob/master/docs/deviations.md
- docs: https://github.com/Roblox/roact-navigation/blob/7393c98889240236d2b8a855bd63fedcbdc4f385/src/routers/_tests_/StackRouter.spec.lua#L87
- docs: https://github.com/Roblox/roact-navigation/blob/master/docs/deviations.md#backbehavior
- docs: https://github.com/Roblox/roact-navigation/blob/master/docs/deviations.md#events-and-addlistener
- docs: https://github.com/Roblox/roact-navigation/blob/master/src/_tests_/createAppContainer.spec.lua
- docs: https://github.com/Roblox/roact-navigation/blob/master/Storybook/StackNavigator/ResetToSpecificStack.story.lua



## Testing tools

### testEZ
- src: https://github.com/Roblox/testez

TestEZ is a testing tool for Roblox projects.

- Roblox/TestEZ is archived in favor of [Roblox/jest-react](#jest-react) (or [jsdotlua/jest-lua](#jest-lua)).
- wally-index hosts testez version 0.4.1: https://github.com/UpliftGames/wally-index/blob/main/roblox/testez


### jest-react
- src: https://github.com/Roblox/jest-roblox

jest-react is a testing tool for Roblox projects.


### jest-lua
- src: https://github.com/jsdotlua/jest-lua

jest-lua is a testing tool for Roblox projects.


## Place and Model tools 

### rbxlx-to-rojo
- src: https://github.com/rojo-rbx/rbxlx-to-rojo
- src: https://github.com/Striker2783/rbxlx-to-rojo
  - fork with linux support


### lune
- docs: https://lune-org.github.io/docs
- https://lune-org.github.io/docs/api-reference/roblox#deserializeplace
- https://github.com/Quenix/lune-workflow-example/blob/main/build/scripts/pull-changes-from-place.lua
- https://github.com/Quenix/lune-workflow-example/blob/main/build/scripts/compare.lua
- https://lune-org.github.io/docs/roblox/3-remodel-migration#differences-between-lune--remodel
  - lune includes the functionality of "remodel" which is not actively maintained


## Transpile to Lua/Luau tools
### roblox-ts
- src: https://github.com/roblox-ts/roblox-ts

## vscode

### vscode extensions
- https://rojo.space/docs/v7/#tools
- https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo [rojo](#rojo)
- https://marketplace.visualstudio.com/items?itemName=JohnnyMorganz.luau-lsp
  https://open-vsx.org/extension/JohnnyMorganz/luau-lsp
- https://marketplace.visualstudio.com/items?itemName=JohnnyMorganz.stylua [stylua](#stylua)
- https://marketplace.visualstudio.com/items?itemName=filiptibell.roblox-ui
- ...


## Linters

### stylua
- cargopkg: stylua

### selene
- src: https://github.com/Kampfkarren/selene
- cargopkg: selene

## Docs tools

### moonwave
- src: https://github.com/evaera/moonwave
- docs: https://eryn.io/moonwave/docs/
- docs: https://eryn.io/moonwave/docs/intro#your-first-class


# TODO roblox studio bugs
- Platform: Roblox Studio With Vinegar
  - IDK if these are reproducible with Windows or Mac without Vinegar/WINE?
    - There's a port of Vinegar to Windows.
  - vinegar config:
    ```
    dxvk=true
    gpu=prime-discrete  # TODO
    ```
  - wine config:
    - font dpi: TODO: low-high

Bugs:

- Drag and drop multiple child nodes from a Part to a Model 
- Drag and drop sticks to the cursor until TODO Vinegar link
- Face-culling artifacts w/ a cube of Instance.new("Part") of EnumType...Block *and transparency*
  
# TODO vinegar bugs
- PrintScr does OS-level screenshots in Gnome (so in-roblox screenshots don't work with the PrintScr shortcut)
- F12 to record a video
  Error: Output: `Call failed 0x12341234'