# AffCom Lab: Secure Whisper Environment

This is the **AffCom Lab Edition** of the GPU-accelerated Whisper environment.

It is built on top of the public `jmgirard/audio-whisper` image but adds a secure "Lab Layer" that allows you to connect directly to the AffCom **Datasets** and **Projects** network shares from inside the container.

### Features
* **GPU Acceleration:** Runs OpenAI's Whisper model on the lab machine's NVIDIA GPU.
* **Pre-Loaded Models:** Uses the Whisper models already stored on the server (no downloads required).
* **Safety Rails:**
    * `/mnt/datasets`: Mounted **Read-Only** (You cannot accidentally delete raw data).
    * `/mnt/projects`: Mounted **Read-Write** (Save your transcripts here).

---

## Prerequisites

1.  **Lab Machine:** This image is designed to run on AffCom lab workstations.
2.  **Docker Desktop:** Installed and running.
3.  **NVIDIA Drivers:** Ensure the machine's drivers are up to date.

---

## Setup & Launch

### 1. Download the Repository
Open a terminal (PowerShell) and run:

```powershell
git clone https://github.com/affcomlab/lab-whisper.git
cd lab-whisper
```

### 2. Start the Environment
Open your terminal (PowerShell) **inside the `lab-whisper` folder** and run:

```powershell
docker compose run --rm whisper-lab
```

* The first time you run this, it will take a moment to build the lab image (`lab-whisper:latest`).
* Subsequent runs will be instant.

### 3. Connect to Lab Drives
Once R launches, you will see a message: `Loaded AffCom Lab Utils`. Run the connection function:

```r
connect_lab_drives()
```

You will be prompted for your **KU Online ID** and **Password**.
* *Note:* Your password is typed securely (it won't show on screen) and is never saved to disk. It exists only in RAM for this session.

If successful, you will see:
> ✅ Mounted: /mnt/datasets (Read-Only)
> ✅ Mounted: /mnt/projects (Read-Write)

---

## Usage Example

You can analyze audio files directly from the server using the pre-downloaded models.

```r
library(audio.whisper)
library(openac)

# 1. Login (if you haven't already)
connect_lab_drives()

# 2. Load Whisper Model from Server
# We use the models stored in datasets/whisper so you don't have to download them.
# Available: "ggml-base.bin", "ggml-small.bin", "ggml-medium.bin", "ggml-large-v3.bin"
model_path <- "/mnt/datasets/whisper/ggml-base.bin"
model <- whisper(model_path, use_gpu = TRUE)

# 3. Transcribe a file from the PROJECTS drive
# (Replace this path with your actual study folder)
audio_path <- "/mnt/projects/MyStudy/Wave1/subject_001.wav"
transcript <- predict(model, newdata = audio_path)

# 4. Save results back to the server
write.csv(transcript, "/mnt/projects/MyStudy/Wave1/subject_001_transcript.csv")
```

---

## Troubleshooting

### "Connection failed" or "Host is down"
* **Check Credentials:** Did you type your password correctly? (The prompt does not show asterisks `***`).
* **Check NetID:** Use just your username (e.g., `jdoe`), not your full email.

### "Permission Denied" when saving files
* **Wrong Folder:** Check where you are trying to save.
    * You **cannot** save to `/mnt/datasets` (Read-Only).
    * You **can** save to `/mnt/projects` (Read-Write).

### "Fatal error: you must specify '--save'..."
* You likely ran `docker-compose up`.
* Always use the run command: `docker compose run --rm whisper-lab`