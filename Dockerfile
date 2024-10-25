FROM python:3.9-slim

WORKDIR /app

# Copy all files to the container
COPY . .

# Install Poetry and dependencies, add Flask
RUN pip install --upgrade pip \
    && pip install poetry \
    && poetry export -f requirements.txt --without-hashes --output requirements.txt \
    && echo "flask" >> requirements.txt \  # Add Flask to requirements
    && pip install --disable-pip-version-check -r requirements.txt \
    && pip install gunicorn 

# Start Gunicorn and vidmergebot in parallel
CMD ["sh", "-c", "python3 -m vidmergebot & python3 vidmergebot/app.py"]
