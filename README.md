# 🎮 Resourcepack Optimize

### Professional Minecraft Resource Pack Compression Framework

Maintained by **ReiiAp**

------------------------------------------------------------------------

## 🌍 Project Overview

Resourcepack Optimize adalah sistem otomatis berbasis GitHub Actions
yang dirancang untuk mengurangi ukuran resource pack Minecraft tanpa
merusak struktur, custom model data, atau integritas visual.

Project ini dibuat untuk: - Developer server Minecraft - Content
creator - Network production environment - Resource pack dengan banyak
audio & texture

Fokus utama: ✔ Preservasi kualitas\
✔ Stabilitas custom model\
✔ Automation workflow\
✔ Efisiensi ukuran file

------------------------------------------------------------------------

# 📚 Table of Contents

-   Optimization Profiles
-   Core Features
-   Usage via GitHub
-   Local Execution
-   Processing Scope
-   Technical Architecture
-   Performance Benchmark
-   Comparison Insight
-   Limitations
-   FAQ
-   Credits
-   License

------------------------------------------------------------------------

# ⚙ Optimization Profiles

## 🟢 Profile A --- Standard Safe Mode

Mode ini dirancang untuk penggunaan umum.

### PNG Handling

-   Multi-pass lossless compression
-   Tidak mengubah RGB value
-   Tidak menyentuh metadata model

### OGG Handling

-   Re-encode bitrate optimal
-   Timing & loudness tetap natural

**Estimasi pengurangan ukuran:** 20%--35%

Direkomendasikan untuk: - Custom model intensive packs - Production
servers - Marketplace-ready packs

------------------------------------------------------------------------

## 🟠 Profile B --- Advanced Audio Mode

Fokus utama: reduksi audio lebih agresif.

### PNG

Sama seperti Profile A (100% lossless).

### OGG

-   Loudness normalization
-   Silence trimming otomatis
-   Bitrate lebih rendah
-   Re-sampling stabil

**Estimasi pengurangan ukuran:** 30%--45%

Trade-off yang perlu diketahui: - Dynamic range berkurang - Beberapa
ambience delay bisa terpotong - Tidak cocok untuk cinematic pack

------------------------------------------------------------------------

# ✨ Core Features

-   Dual optimization profile
-   100% safe untuk custom model data
-   GitHub Actions automation
-   Parallel processing engine
-   Error-tolerant execution
-   Before/after size report
-   Artifact auto packaging
-   Cross-platform compatible

------------------------------------------------------------------------

# 🚀 Usage via GitHub Automation

1.  Upload resource pack (.zip) ke public hosting
2.  Buka tab Issues
3.  Pilih template sesuai profile
4.  Masukkan link file
5.  Submit
6.  Tunggu workflow selesai
7.  Download artifact hasil optimasi

Artifact yang tersedia: - optimized-pack-standard - optimized-pack-audio

Estimasi waktu proses: - 15--20 menit (Standard) - 20--25 menit
(Advanced Audio)

------------------------------------------------------------------------

# 💻 Local Execution Guide

Clone repository:

``` bash
git clone https://github.com/reiiap/Resourcepack-Optimize.git
cd Resourcepack-Optimize
chmod +x optimize_script.sh
./optimize_script.sh
```

Kemudian pilih profile sesuai kebutuhan.

Output: - optimized-pack-standard.zip - optimized-pack-audio.zip

------------------------------------------------------------------------

# 📂 Processing Scope

## Files Processed

  Extension   Treatment
  ----------- ------------------------
  .png        Lossless recompression
  .ogg        Audio re-encoding

## Files Ignored

-   .json
-   .mcmeta
-   .properties
-   .txt
-   .fsh / .vsh
-   Folder structure

Struktur directory selalu dipertahankan.

------------------------------------------------------------------------

# 🧠 Technical Architecture

## PNG Pipeline

1.  Primary compression pass\
2.  Secondary recompression\
3.  Integrity validation

Semua tahap memastikan pixel data tidak berubah.

## Audio Pipeline (Advanced Mode)

-   Loudness normalization (target balanced LUFS)
-   Silence detection & trimming
-   Vorbis encoding tuning
-   Sample rate validation

------------------------------------------------------------------------

# 📊 Performance Benchmark

### Sample Case A

  Metric            Value
  ----------------- -----------
  Original Size     32 MB
  Optimized         23 MB
  Reduction         28%
  Model Integrity   Preserved

### Sample Case B (Audio-heavy)

  Original   Optimized   Reduction
  ---------- ----------- -----------
  50 MB      34 MB       32%
  70 MB      45 MB       35%

Hasil aktual tergantung distribusi texture & audio.

------------------------------------------------------------------------

# 🆚 Comparison Insight

  Feature               Resourcepack Optimize   Generic Compressor
  --------------------- ----------------------- --------------------
  Custom Model Safety   Yes                     Not guaranteed
  Dual Profile          Yes                     Rare
  GitHub Automation     Yes                     No
  Parallel Engine       Yes                     Limited
  Audio Control         Advanced                Basic

------------------------------------------------------------------------

# ⚠ Limitations

Standard Mode: - Audio reduction tidak agresif

Advanced Mode: - Dynamic range berkurang - Silence removal bisa mengubah
feel ambience - Tidak disarankan untuk music disc berkualitas tinggi

------------------------------------------------------------------------

# ❓ Frequently Asked Questions

### Apakah aman untuk custom model?

Ya. Tidak ada manipulasi JSON atau texture mapping.

### Apakah warna texture berubah?

Tidak. Compression dilakukan secara lossless.

### Bisa digunakan ulang berkali-kali?

Bisa, tetapi gain tambahan biasanya kecil.

### Kapan sebaiknya pakai Advanced Mode?

Saat pack memiliki banyak audio file dan prioritas utama adalah size
reduction.

------------------------------------------------------------------------

# 👤 Maintainer

ReiiAp
GitHub: https://github.com/reiiap
Repository: https://github.com/reiiap/Resourcepack-Optimize

------------------------------------------------------------------------

# 🤝 Contributing

Pull request terbuka untuk: - Optimization improvement - Bug fix -
Feature proposal

Gunakan tab Issues untuk report bug atau request enhancement.

------------------------------------------------------------------------

# 📄 License

Distributed under the MIT License.
