# MPC-Sample-Prep

Utility for scanning and normalizing audio sample folders and filenames.

## Overview

`CheckSample.sh` is a POSIX shell script designed to help with managing
collections of WAV samples. It provides three main functions:

1. **Folder name length check** – identifies subdirectories whose final
   component exceeds a configurable character limit.
2. **File name length check** – locates WAV files with long names (excluding
   spaces) and logs them for review.
3. **Audio normalization** – uses `sox` to resample files to 44.1 kHz and
   convert encoding to 16‑bit, writing problematic paths to log files and
   creating `RS_`‑prefixed copies when processing is performed.

The script is menu driven and intended to run on Unix‑like environments
(Linux, macOS, Cygwin, WSL, Git‑bash, etc.).

## Requirements

* A POSIX‑compatible shell (`/bin/sh`, `bash`, `dash`, etc.)
* `find`, `rev`, `cut`, `sox` utilities available on `PATH`
* No spaces in the `sample_path` variable by default, although the script
  attempts to escape spaces internally.

> **Note:** Windows PowerShell does not provide a suitable shell. Use WSL,
> Git‑bash, or another Unix layer to execute the script.

## Usage

1. Make the script executable:
   ```sh
   chmod +x CheckSample.sh
   ```
2. Edit the `sample_path`, `FOLDERTAM`, and `FILETAM` variables near the top
   of the file if the defaults do not suit your collection.
3. Run it:
   ```sh
   ./CheckSample.sh
   ```
4. Choose one of the menu options (1–3) to perform the corresponding action.
   Log output is appended to `renamefolders.log`, `renamefiles.log`,
   `resamplefiles.log`, and `badfiles.log` in the current directory.

## Configuration

* `sample_path` – root directory to inspect (must not contain whitespace).
* `FOLDERTAM` – maximum allowed characters for a folder name component.
* `FILETAM` – maximum allowed characters for a filename (spaces excluded).

## Notes & Caveats

* Triple‑quoted blocks in the script are not valid shell comments and will
  produce errors; they exist purely for documentation and should be replaced
  with `#` comments if the script is used.
* Filenames containing `&` or other shell‑metacharacters may still break the
  `find` command; process with caution or escape them manually.
* The script uses `eval` unnecessarily in a few places; these could be
  simplified without changing behavior.

## License

This repository contains sample utility code for internal use. Adjust as
needed for your own projects.
