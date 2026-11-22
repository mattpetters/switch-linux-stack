# switch-linux-stack

Pinned copies of the source stack for running Ubuntu on a Nintendo Switch (the Switchroot "L4T Ubuntu Noble 24.04" project; L4T is Linux for Tegra, NVIDIA's Linux for the Switch's Tegra X1 chip). Each of the 27 components is a git submodule of a copy in the owner's GitHub account, pinned to an exact commit, so the stack can be rebuilt and maintained if the upstream project disappears.

Pins are listed in [stack.lock.tsv](stack.lock.tsv): path, our copy, upstream, branch, commit, and why that branch. The eight kernel inputs use the branches that the kernel build script (`l4t-linux-build.sh`, default values of NX_VER, NV_VER, NG_VER, DT_VER) chooses; everything else uses the default branch of our copy. Note: `kernel/switch-l4t-kernel-nvgpu` and `kernel/l4t-kernel-nvgpu` currently point at the same commit.

Upstream project: Switchroot, wiki at <https://wiki.switchroot.org/wiki/>.

## Components

| Path | What it is | Status |
|---|---|---|
| `build/l4t-image-buildscripts` | Scripts that assemble the Ubuntu disk image for the Switch | tool (built from source) |
| `build/l4t-kernel-build-scripts` | Script that downloads the kernel and its inputs and compiles them (l4t-linux-build.sh) | tool (built from source) |
| `build/bootstack-build-scripts` | Scripts for building the boot stack (the programs that start before Linux) | tool; use not verified |
| `kernel/switch-l4t-kernel-4.9` | The Linux 4.9 kernel adapted for the Switch | built from source |
| `kernel/switch-l4t-kernel-nvidia` | NVIDIA kernel-side driver sources (the kernel's nvidia directory) | built from source |
| `kernel/switch-l4t-platform-t210-nx` | Hardware description files (device tree) for the Switch board, Tegra X1 (code name t210) variant nx | built from source |
| `kernel/l4t-kernel-nvgpu` | NVIDIA GPU kernel driver (nvgpu), GitLab copy used by the build script | built from source |
| `kernel/l4t-soc-t210` | Tegra X1 chip hardware description files | built from source |
| `kernel/l4t-soc-tegra` | Common Tegra chip hardware description files | built from source |
| `kernel/l4t-platform-tegra-common` | Hardware description files shared by Tegra boards | built from source |
| `kernel/l4t-platform-t210-common` | Hardware description files shared by Tegra X1 boards | built from source |
| `kernel/switch-l4t-kernel-nvgpu` | CTCaer's fork of the GPU kernel driver; alternative copy, not used by the build script | alternative copy; not used by build script |
| `boot/hekate` | Bootloader with a graphical menu that launches Linux on the Switch | image uses a prebuilt copy (upstream-reported) |
| `boot/switch-l4t-atf` | CTCaer's ARM Trusted Firmware (small secure-world program that runs before the OS), version 5 line | image uses prebuilt boot files (upstream-reported) |
| `boot/switch-atf` | Switchroot's ARM Trusted Firmware, version 4 line (GitLab mirror) | image uses prebuilt boot files (upstream-reported) |
| `boot/switch-l4t-uboot` | CTCaer's U-Boot (the boot loader that loads the Linux kernel) | image uses prebuilt boot files (upstream-reported) |
| `boot/switch-uboot` | Switchroot's U-Boot (GitLab mirror) | image uses prebuilt boot files (upstream-reported) |
| `boot/switch-uboot-scripts` | U-Boot boot scripts | not verified |
| `boot/switch-coreboot` | Coreboot (open-source firmware) port for the Switch | not verified |
| `packages/l4t-debs` | APT repository of ready-made .deb packages for Ubuntu Jammy and Noble (about 5 GB) | shipped as prebuilt binary |
| `packages/l4t-debs-source` | Source for the packages, plus the prebuilt boot files the image uses | built from source (boot files prebuilt, upstream-reported) |
| `packages/switch-l4t-configs` | Configuration files installed on the Switch image | not verified |
| `packages/joycond` | Userspace daemon that pairs Joy-Cons using the kernel's hid-nintendo driver (GitHub fork) | built from source |
| `packages/switchroot-joycond` | Switchroot's copy of the Joy-Con daemon (GitLab mirror) | built from source |
| `packages/vk_layer_tegra_dc_present` | Vulkan layer that works around broken vsync on NVIDIA Tegra | built from source |
| `packages/FFmpeg` | FFmpeg video tools with NVIDIA hardware decode (branch 6.1.1-nvv4l2) | built from source |
| `extras/L4T-Megascript` | All-in-one installer for popular programs on L4T Ubuntu | built from source (scripts) |

"Status" combines what the upstream project's own documents and scripts say with the brief this repo was made from; "not verified" means nobody has checked.

## Fetching only what you need

```
git clone https://github.com/mattpetters/switch-linux-stack
cd switch-linux-stack
git submodule update --init build/l4t-kernel-build-scripts
```

Warnings: `kernel/` must be checked out on Linux (the kernel contains file names that differ only by case, which a case-insensitive Mac disk cannot hold). `packages/l4t-debs` is about 5 GB, and several other components are 1 GB or more. Do not run a bare `git submodule update --init` unless you want everything.

## Known limits (as reported by the upstream project's own documents and scripts)

- The image uses prebuilt boot files committed inside `l4t-debs-source` rather than building them.
- The source of the newest startup image (initramfs, the small system that runs first at boot) and two firmware files supplied by hekate are not public.
- NVIDIA's driver packages are closed; they are preserved only as binaries inside `l4t-debs`.
- Every release runs the same Linux 4.9 kernel.
- The kernel build script downloads its compiler (gcc-linaro-7.5.0-2019.12) from releases.linaro.org. That download no longer works: on 2026-11-22 the URL redirected to a contact page (checked by this repo's author).

## Build inputs that are not git repositories

The build scripts also download three files that live in no repository. Copies are attached to the [inputs-2026-11-22 release](https://github.com/mattpetters/switch-linux-stack/releases/tag/inputs-2026-11-22), and [inputs.tsv](inputs.tsv) records each one's size, SHA-256, where it was fetched from and how it was checked:

- the compiler for the kernel (the Linaro download that stopped working, recovered from a third-party copy whose checksums match independent records and Linaro's own),
- the minimal Ubuntu 24.04 system the image is built on,
- Google's device-tree overlay tools.

NVIDIA's closed driver packages and the prebuilt boot files are not in the release: they are already inside `packages/l4t-debs` and `packages/l4t-debs-source`.

## Kernel build

The workflow [.github/workflows/kernel-build.yml](.github/workflows/kernel-build.yml) compiles the Linux 4.9 kernel for the Switch on a standard free GitHub runner (Ubuntu 22.04) using only this repo's copies. It checks out just the eight kernel submodules plus `build/l4t-kernel-build-scripts` at their pinned commits, downloads the compiler and Google's device-tree tools from the [inputs-2026-11-22 release](https://github.com/mattpetters/switch-linux-stack/releases/tag/inputs-2026-11-22) and checks their SHA-256 against [inputs.tsv](inputs.tsv), then runs a copy of the upstream build script. Three edits are made to that copy, each asserting that it matched: the eight `git clone` lines are made to abort (the sources are already in place), and the compiler and libufdt `wget` lines become copies of the verified files. A last step fails the job if any executed line still names github.com/theofficialgman, gitlab.com/switchroot, releases.linaro.org or android.googlesource.com. Outputs (`uImage`, `nx-plat.dtimg`, `modules.tar.gz`) are kept as an artifact for 3 days, and the job summary lists the kernel version, file sizes and input commits.

Run it: `gh workflow run kernel-build.yml -R mattpetters/switch-linux-stack`, then `gh run watch`.

Status: green on 2026-11-22, [run 45046993524](https://github.com/mattpetters/switch-linux-stack/actions/runs/45046993524), build time 9 min 59 s, kernel `Linux version 4.9.140-l4t ... gcc 7.5.0 (Linaro GCC 7.5-2019.12)`. `uImage` is 10,366,360 bytes and `nx-plat.dtimg` is 668,846 bytes (the installed image ships 10,359,243 and 668,726).

What this does not prove: the kernel has not been booted on a Switch, and only the kernel is built, not the boot files (hekate, ATF, U-Boot) or the disk image. The build still downloads Ubuntu packages (apt) and GitHub Actions components, and GitHub itself hosts the sources.

## Scripts

- `scripts/verify.sh`: checks that each pinned commit is still reachable in our copy and that the submodule pointer matches the lock file; exits non-zero on mismatch.
- `scripts/sync.sh [--dry-run]`: asks GitHub to update forks from their upstream, prints the manual command for GitLab mirrors, then rewrites the pins and lock file. Use `--dry-run` first.

## Licence

This repo adds no licence of its own. Each component keeps its own licence.
