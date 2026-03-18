FROM python:3.11-slim

WORKDIR /app

# Install system dependencies if required (e.g. for pypdf)
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    software-properties-common \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt .
RUN pip3 install -r requirements.txt

# Copy the rest of the app
COPY . .

# Expose port for Streamlit
EXPOSE 8501

# Run the application
ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]
