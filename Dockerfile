FROM ghcr.io/divkix/docker-python-base:latest

WORKDIR /app
COPY . .

# Export dependencies using poetry and install them
RUN poetry export -f requirements.txt --without-hashes --output requirements.txt \
    && pip install --disable-pip-version-check -r requirements.txt

# Expose port 8000 to be accessible from outside the container
EXPOSE 8000

# Start both gunicorn for app.py and vidmergebot in parallel
CMD gunicorn -b 0.0.0.0:8000 app:app & python3 -m vidmergebot
