# ---------- base ----------
FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    TZ=Europe/Istanbul

# FFmpeg + sistem bağımlılıkları
RUN apt-get update && apt-get install -y --no-install-recommends \
      ffmpeg curl ca-certificates git tini \
    && rm -rf /var/lib/apt/lists/*

# İsteğe bağlı: non-root kullanıcı
RUN useradd -ms /bin/bash appuser
WORKDIR /app
USER appuser

# Python bağımlılıkları
# Not: openai-whisper, PyTorch'u otomatik getirir (CPU tekeri).
RUN pip install --upgrade pip \
 && pip install "openai-whisper>=20231117" numpy soundfile

# Test: sürümleri cache dışı yazdır (build log için)
RUN python -c "import whisper, sys; print('whisper', whisper.__version__); print(sys.version)" \
 && ffmpeg -version | head -n 1

# Paylaşımlı veri klasörü (n8n vb. ile)
VOLUME ["/data"]

# Konteyner ayakta kalsın (servis gibi)
ENTRYPOINT ["/usr/bin/tini","--"]
CMD ["bash","-lc","echo 'Container ready. Use /data for I/O. whisper & ffmpeg available.' && tail -f /dev/null"]
