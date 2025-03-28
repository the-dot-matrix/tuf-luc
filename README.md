# tuf/luc
## Towards Understanding Fengari / Lua Uninterpreted Compilation

### Goal
To understand and hopefully improve Lua performance in browser.
The current options, compared to local machine compilers, JIT or otherwise, is not good.
This is a major bottleneck for many projects to be ported to the web.
Namely realtime graphics, and in this case, supporting love2d/lovejs.

### Results
#### Testing Apparatus
- **Machine:** [Retina Mid-2012 MacBookPro10,1 A1398](https://everymac.com/systems/apple/macbook_pro/specs/macbook-pro-core-i7-2.6-15-mid-2012-retina-display-specs.html)
- **GPU:** NVidia GeForce 650M Mac Edition, nvidia-390 proprietary driver
- **Operating System:** Ubuntu 20.04 LTS (next LTS drops gpu driver support from the kernel)
- **Browser:** Firefox 136.0
- **Test:** a basic, in-place, merge-sort implementation on 10k random lists at various orders of magnitude
#### Offline Performance
- **[lua5.1](https://www.lua.org/versions.html#5.1):** 12 seconds
- **[lua5.4](https://www.lua.org/versions.html#5.4):** 6 seconds
- **[luajit](https://github.com/LuaJIT/LuaJIT):** 1 second
#### Online Performance
- **[fengari (Lua 5.3 VM)](https://github.com/fengari-lua/fengari):** 169 seconds
- **[Emscripten](https://github.com/emscripten-core/emscripten):** TBD
#### Novel Implementations to be investigated and developed...
##### ... in order of increasing non-triviality
- **Clear extension, [Decent Blog Post](https://cfallin.org/blog/2024/08/28/weval/):** [WASM partial eval](https://github.com/bytecodealliance/weval?tab=readme-ov-file), 1st Futamura Projection, Interpreter->Compiler
- **Incomplete artifact:** [alternative WASM linking pipelines](https://github.com/wingo/wasm-jit) for dynamic code generation in browser
- **Enigmatic:** [WASM JIT prototypes in old emscripten issue tracker](https://github.com/emscripten-core/emscripten/issues/7082), not exactly JIT, more like dynamic wasm module extension/linking
- **Heroic:** JIT/FFI-less port of LuaJIT to native WASM, or purely-C port that can be compiled to WASM
