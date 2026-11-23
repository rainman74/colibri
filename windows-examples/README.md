# Windows example scripts — colibri on a 10 GB RTX 3080

Launcher scripts for [colibri](https://github.com/JustVugg/colibri) (JustVugg/colibri, Apache-2.0)
that serve **Inkling-2-Mini** from the published GGUF files through `coli serve` and `coli chat`.

They deliberately use the **same port (9931) and model id (`llama-home`)** as the llama.cpp
scripts in this profile, so a client such as OpenClaw can switch between the two engines without
changing a single line of its configuration.

---

## 1. Folder layout

```
windows-examples\
├── clserver_Inkling-2-Mini-UD-Q2_K_XL.cmd   server  9.14 GB  ctx 100000
├── clserver_Inkling-2-Mini-UD-Q3_K_XL.cmd   server 13.63 GB  ctx 100000
├── clserver_Inkling-2-Mini-UD-Q4_K_XL.cmd   server 17.63 GB  ctx 100000
├── clstart_Inkling-2-Mini-UD-Q2_K_XL.cmd    CLI chat (same three quants)
├── clstart_Inkling-2-Mini-UD-Q3_K_XL.cmd
├── clstart_Inkling-2-Mini-UD-Q4_K_XL.cmd
├── clstop.cmd                               stop the server and the engine
├── clcheck.cmd                              memory, GPU, engine and API status
├── cltest.cmd                               API smoke test
└── clhelp.cmd                               dump the launcher's --help pages
```

**No `models\` folder in the repository.** The GGUFs, the vision projector and the scripts live
together in the runtime folder (`%APPPATH%\colibri`), because the scripts resolve everything
relative to their own location (`set "BASE=%~dp0"`).

---

## 2. Requirements

| | |
|---|---|
| Python | **3 in `PATH`** — the colibri launcher (`c/coli`) is a Python program, the engines are not |
| Checkout | a local clone of colibri; every script has `set "COLI_REPO=D:\Sources\colibri"` at the top |
| Engines | the release binaries (`inkling.exe`, `coli_cuda.dll`, `cudart64_12.dll`) next to the scripts |
| Shaders | `shaders\` next to the engine binaries — **131 files, 3.3 MB**, copied from `<checkout>\c\shaders` |
| GPU | NVIDIA recommended; the engine prefers CUDA for Inkling-2 when built with both backends |

Without `shaders\` the engine logs `cannot open shaders/qmatmul.spv` and silently runs on the CPU.

---

## 3. Script catalogue

### Server scripts

Start `coli serve` in the foreground; `Ctrl+C` or `clstop.cmd` stops it.

| Script | Quant | Size | ctx | Port | Backend |
|---|---|---|---|---|---|
| `clserver_Inkling-2-Mini-UD-Q2_K_XL.cmd` | `Q2_K_XL` | 9.14 GB | 100000 | 9931 | CUDA |
| `clserver_Inkling-2-Mini-UD-Q3_K_XL.cmd` | `Q3_K_XL` | 13.63 GB | 100000 | 9931 | CUDA |
| `clserver_Inkling-2-Mini-UD-Q4_K_XL.cmd` | `Q4_K_XL` | 17.63 GB | 100000 | 9931 | CUDA |

### CLI scripts

`clstart_<quant>.cmd` runs `coli chat` on the same model — the terminal chat, no HTTP.

### Helper scripts

| Script | Purpose |
|---|---|
| `clstop.cmd` | `coli stop`, then kills a leftover `inkling.exe`, checks port 9931, prints GPU memory |
| `clcheck.cmd` | Python, engine processes, RAM, VRAM and whether the API answers |
| `cltest.cmd` | One question against `/v1/chat/completions`, prints the answer |
| `clhelp.cmd` | Writes `colibri-help.txt`, `colibri-serve.txt`, `colibri-chat.txt`, `colibri-import.txt` |

### Variables

| Variable | Meaning |
|---|---|
| `COLI_REPO` | the colibri checkout that holds `c\coli` |
| `COLI` | `<COLI_REPO>\c\coli` (the launcher) |
| `COLI_ENGINE` | `%BASE%inkling.exe` — see § 5, the launcher does not search the runtime folder |
| `GGUF` / `SNAP` | the model file and the imported model directory next to it |
| `CTX` | context length handed to `coli serve` / `coli chat` |
| `PORT` / `MODELID` | 9931 and `llama-home`, identical to the llama.cpp scripts |
| `COLI_VULKAN` / `COLI_CUDA` / `COLI_GPU` | force the CUDA backend on device 0 |
| `COLI_PREFIX_STORE` | `0` disables the prompt-prefix cache (it takes 3.6 GB of VRAM) |
| `CUDA_EXPERT_GB` | VRAM budget for the expert tier, `auto` = what is free |

---

## 4. Port and model id

```
alias   llama-home
port    9931
API     http://<host>:9931/v1   (OpenAI compatible)
WebUI   http://<host>:9931
```

Same values as the llama.cpp scripts on purpose. **Only one of the two engines can run at a
time** — both want 9931 and both want the GPU.

---

## 5. How a script works

1. **Engine path.** The launcher searches `<checkout>\libexec\colibri\` and `<checkout>\c\` for an
   engine binary. The release binaries live in the runtime folder instead, so every script sets
   `COLI_ENGINE=%BASE%inkling.exe`. Without it the launcher stops with
   `inkling engine is not built. Run: make -C c inkling`.
2. **Working directory.** The engine opens `shaders/<name>.spv` relative to its current
   directory, so the scripts `pushd "%BASE%"` before starting and `popd` afterwards.
3. **First run.** `coli import "<gguf>"` writes `<quant>.colibri` next to the model — `config.json`,
   tokenizer, chat template and a `gguf.json` that points at the file (`mode: link`, nothing is
   copied). The scripts do this automatically when the directory is missing.
4. **Backend.** `COLI_VULKAN=0 COLI_CUDA=1 COLI_GPU=0` forces CUDA. This matters: with Vulkan the
   engine refuses the GGUF expert types and runs every expert on the CPU.
5. **Sampling.** `--temp 1.0 --topp 1.0 --topk 0` is the checkpoint's own recommendation
   (`generation_config.json`: `do_sample: true, temperature: 1.0`, no truncation parameters).

---

## 6. Model files

All files belong in the runtime folder's `models\`. Sizes are decimal GB, links verified (HTTP 200).

| File | Size | Download |
|---|---|---|
| `Inkling-2-Mini-UD-Q2_K_XL.gguf` | 9.14 GB | [download](https://huggingface.co/unsloth/Inkling-2-Mini-GGUF/resolve/main/Inkling-2-Mini-UD-Q2_K_XL.gguf) |
| `Inkling-2-Mini-UD-Q3_K_XL.gguf` | 13.63 GB | [download](https://huggingface.co/unsloth/Inkling-2-Mini-GGUF/resolve/main/Inkling-2-Mini-UD-Q3_K_XL.gguf) |
| `Inkling-2-Mini-UD-Q4_K_XL.gguf` | 17.63 GB | [download](https://huggingface.co/unsloth/Inkling-2-Mini-GGUF/resolve/main/Inkling-2-Mini-UD-Q4_K_XL.gguf) |
| `mmproj-F16.gguf` (vision tower) | 0.64 GB | [download](https://huggingface.co/unsloth/Inkling-2-Mini-GGUF/resolve/main/mmproj-F16.gguf) |

**Vision.** The import links `mmproj-F16.gguf` when it sits next to the GGUF and writes the
projector's `vision_config`; the API then advertises `input_modalities: ["text", "image"]`.
`mmproj-F32.gguf` (1.27 GB) is the same tower at double precision — twice the size, no measurable
gain, so `F16` is what the import picks.

**The DSpark drafter is not used here.** colibri loads its MTP head from
`<model>.colibri\mtp\mtp.safetensors`, which a GGUF import does not create — so there is no
speculative decoding, unlike the llama.cpp scripts.

**`imatrix_unsloth.gguf` is not a model.** It is Unsloth's importance matrix, calibration data for
`llama-quantize --imatrix`; colibri refuses it on purpose
(`this GGUF is an importance matrix (imatrix): calibration data for quantizing, not a model to run`).

---

## 7. Measured on an RTX 3080 (10 GB), IQ2_XXS, CUDA

| ctx | VRAM for the expert tier | experts resident | decode |
|---|---|---|---|
| 100000 | 341 MiB | 74 of 3072 | 1.15 t/s |
| 49152 | 3.45 GiB | 1496 | 2.88 t/s |
| 16384 | 5.45 GiB | 2400 | 4.93 t/s |

colibri keeps the **KV cache in VRAM** (about 7 GB at 100k, no option to move it), so context and
expert residency compete for the same 10 GB. With `IQ1_S` (7.76 GB) the tier grows to 3.45 GiB at
100k and the decode reaches 1.41 t/s.

**llama.cpp with the same model class on the same card: 22–26 t/s at 100k context**, because it
keeps the weights in VRAM and the KV cache in RAM (`--no-kv-offload`). colibri is the better
engine only on cards with 24 GB or more, where the whole expert set stays resident.

---

## 8. Known issues

- **`[env] unknown variable COLI_ENGINE`** at startup — the engines do not read that variable, only
  the launcher does. Harmless, it is inherited by the child process.
- **`[env] TEMP is not read by inkling`** — Windows always sets `TEMP` (the temp directory);
  colibri's environment checker reads it as a sampling variable. Harmless: the temperature is
  passed as `--temp`.
- **No KV cache in RAM.** There is only `COLI_KV_PREFIX` and `COLI_KV_SHARE`; the cache always
  lives on the device.
- **`coli import` needs read access to the GGUF.** A file still being copied fails with
  `PermissionError: [Errno 13]`.
- **The expert tier budget is small on 10 GB.** `CUDA_EXPERT_GB` raises it only up to what the
  planner leaves after the KV cache; forcing `--vram 10` made it smaller, not larger.
