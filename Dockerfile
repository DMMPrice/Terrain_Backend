# Use a stable Debian base (bookworm) instead of trixie
FROM python:3.11-slim-bookworm

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=6000

# Install system dependencies (for numpy/pandas/matplotlib)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gfortran \
    libopenblas-dev \
    liblapack-dev \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Install Python dependencies first (for better layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project (including model/*.pkl)
COPY . .

# Expose the Flask port
EXPOSE 6000

# Run your Flask app
CMD ["python", "app.py"]
