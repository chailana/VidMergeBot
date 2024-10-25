FROM python:3.9-slim

WORKDIR /app
COPY . .

# Install Poetry
RUN pip install --upgrade pip && \
    pip install poetry

# Export dependencies using poetry and install them, including Gunicorn
RUN poetry export -f requirements.txt --without-hashes --output requirements.txt \
    && pip install --disable-pip-version-check -r requirements.txt \
    && pip install gunicorn  # Explicitly add Gunicorn

# Expose port 8000
EXPOSE 8000

# Start Gunicorn and vidmergebot in parallel
CMD gunicorn app:app & python3 -m vidmergebot
