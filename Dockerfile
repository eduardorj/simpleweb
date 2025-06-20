# syntax=docker/dockerfile:1

# --- Builder Stage (to install dependencies) ---
# Use a slim Python image for a smaller final image size
FROM python:3.9-slim as builder

# Set environment variables to prevent Python from writing .pyc files and to buffer output
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# --- Final Stage (to run the application) ---
FROM python:3.9-slim

WORKDIR /app

# Copy installed packages and binaries (like gunicorn) from the builder stage
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy the application source code
COPY app.py .
COPY templates templates

# Create a non-root user for security and switch to it
RUN useradd --create-home appuser
USER appuser

# Run the application using Gunicorn. Cloud Run sets the PORT environment variable.
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "1", "app:app"]