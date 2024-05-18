FROM python:3.9

RUN pip install --upgrade pip
RUN pip install moviepy

COPY generator.py .
COPY run.py .

CMD ["python", "run.py"]
