# Stage 1: Build stage
FROM python:3.12.4-alpine as builder

# Set environment variables
ENV BEANCOUNT_FILE /bean/main.bean
ENV APP_MODULE management.wsgi

# Install build dependencies
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories & \
        apk update && \
        apk add --no-cache --virtual .build-deps \
        gcc \
        libc-dev \
        libxml2-dev \
        libxslt-dev

# Set work directory
WORKDIR /app

# Copy requirements and install dependencies in a virtual environment
COPY requirements.txt .
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt

# Stage 2: Final stage
FROM python:3.12.4-alpine

# Set environment variables
ENV BEANCOUNT_FILE /bean/main.bean
ENV APP_MODULE management.wsgi
ENV USERNAME admin
ENV PASSWORD 123456

# Set work directory
WORKDIR /app

# Copy virtual environment from builder image
COPY --from=builder /app/venv ./venv

# Copy application files
COPY . .

# Copy prestart script
COPY docker/prestart.sh ./prestart.sh

# Ensure scripts are executable
RUN chmod +x ./prestart.sh

# Collect static files and update settings
RUN . venv/bin/activate && yes | python manage.py collectstatic && \
    sed -i 's/DEBUG = True/DEBUG = False/g' management/settings.py

# Expose the port (if needed)
EXPOSE 8000

# Define the default command
CMD ["sh", "-c", "/app/venv/bin/activate && ./prestart.sh && /app/venv/bin/python manage.py runserver 0.0.0.0:8000"]
