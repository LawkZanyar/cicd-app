# Start from an official Python base image (slim = smaller size)
FROM python:3.11-slim

# Set the working directory inside the container
# All subsequent commands run from this folder
WORKDIR /app

# Copy requirements.txt first (before the rest of the code)
# This is done for caching — if requirements don't change, Docker
# skips re-installing them on the next build, saving time
COPY requirements.txt .

# Install the Python packages listed in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy all remaining app files into the container
COPY . .

# Tell Docker this container listens on port 5000
EXPOSE 5000

# The command that runs when the container starts
CMD ["python", "app.py"]