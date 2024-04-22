FROM python:3.10-slim-buster

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app/web

COPY requirements.txt /app/web
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -r /app/web/requirements.txt
COPY . /app/web
