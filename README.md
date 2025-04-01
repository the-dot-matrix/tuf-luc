# tuf/luc
## Towards Understanding Fengari / Lua Uninterpreted Compilation

### Goal
To understand and hopefully improve Lua performance in browser.
The current options, compared to local machine compilers, 
    JIT or otherwise, is not good.
This is a major bottleneck for many projects 
    to be ported to the web.
Namely realtime graphics, and in this case, 
    supporting love2d/lovejs.

### Test
#### Apparatus
- **Machine:** Retina Mid-2012 MacBookPro10,1 Model-A1398
- **GPU:** NVidia GeForce650M MacEdition, nvidia-390 ppa-driver
- **Operating System:** Ubuntu 20.04 LTS (last GPU support LTS)
- **Test:** a basic, in-place, merge-sort implementation,
    on 10k random lists at various orders of magnitude
#### Results
|**lua**|**platform**|**browser**|**runtime**|
|-------|------------|-----------|-----------|
|  jit  |localmachine|  offline  |  1 second |
| 5.4.7 |localmachine|  offline  |  6 seconds|
| 5.1.5 |localmachine|  offline  | 12 seconds|
| 5.4.7 | emsdk4.0.6 |Chrome 135.| 23 seconds|
| 5.4.7 | emsdk4.0.6 |Firefox 136| 25 seconds|
| 5.1.5 | emsdk4.0.6 |Firefox 136| 30 seconds|
| 5.1.5 | emsdk4.0.6 |Chrome 135.| 47 seconds|
| 5.3.x | fengari.js |Chrome 135.|120 seconds|
| 5.3.x | fengari.js |Firefox 136|182 seconds|

### Current Implementations waiting to be reproduced
- **TODO:** add luastatic executables to build script
- **fengari redux:** build from source, see if it's better
- **love.js:** assuming similar to emscripten, TBD

### Novel Implementations to be investigated and developed...
#### ... in order of increasing non-triviality
- **my own lua.wasm vm:** why is fengari so slow?
- **Clear extension, 
    [Blog Post](https://cfallin.org/blog/2024/08/28/weval/):** 
    [partial eval](https://github.com/bytecodealliance/weval), 
    1st Futamura Projection, Interpreter->Compiler
- **Incomplete artifact:** 
    [alternative linking](https://github.com/wingo/wasm-jit) 
    for dynamic code generation in browser
- **Enigmatic:** WASM JIT prototypes, emscripten issue tracker:
    https://github.com/emscripten-core/emscripten/issues/7082
    not exactly JIT, more like wasm module snapshot extensions
- **Heroic:** JIT/FFI-less port of LuaJIT to native WASM, 
    or purely-C port that can be compiled to WASM
