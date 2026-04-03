FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["sh", "-c", "python -c 'from database import engine; from models import Base; Base.metadata.create_all(engine)' && uvicorn main:app --host 0.0.0.0 --port 8000"]