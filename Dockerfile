# Use a slim version of Python 3.9 as the base image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy only the necessary files for dependency installation first
COPY pyproject.toml poetry.lock ./

# Install Poetry for dependency management
RUN pip install --upgrade pip && \
    pip install poetry

# Install dependencies without using virtualenv
RUN poetry config virtualenvs.create false && \
    poetry install --no-root --only main  # Use --only main instead of --no-dev

# Copy the rest of the application code
COPY . .

# Explicitly add Gunicorn
RUN pip install gunicorn

# Copy the start.sh script and make it executable
RUN chmod +x start.sh

# Use the shell form of CMD to run both commands
CMD ["sh", "-c", "python3 -m vidmergebot & python3 app.py"]
