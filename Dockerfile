# Use a slim version of Python 3.9 as the base image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy all files into the container
COPY . .

# Install Poetry for dependency management
RUN pip install --upgrade pip && \
    pip install poetry

# Lock the dependencies and install them, including Gunicorn
RUN poetry lock --no-update && \
    poetry export -f requirements.txt --without-hashes --output requirements.txt && \
    pip install --disable-pip-version-check -r requirements.txt && \
    pip install gunicorn  # Explicitly add Gunicorn

# Copy the start.sh script and make it executable
RUN chmod +x start.sh

# Use a shell to start Gunicorn and vidmergebot in parallel using start.sh
CMD ["sh", "-c", "./start.sh"]
