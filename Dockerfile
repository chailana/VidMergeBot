FROM python:3.9-slim

# Install ffmpeg and other necessary packages
RUN apt-get update && apt-get install -y \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*  # Clean up to reduce image size

WORKDIR /app

# Copy all files to the container
COPY . .

# Install Poetry and dependencies, add Flask
RUN pip install --upgrade pip \
    && pip install poetry \
    && poetry export -f requirements.txt --without-hashes --output requirements.txt \
    && echo "flask" >> requirements.txt  # Add Flask to requirements

RUN pip install --disable-pip-version-check -r requirements.txt \
    && pip install gunicorn 

# Start Gunicorn and vidmergebot in parallel
CMD ["sh", "-c", "gunicorn vidmergebot.app:app & python3 -m vidmergebot"]
