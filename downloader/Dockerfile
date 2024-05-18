FROM python:3.9

RUN pip install --upgrade pip
RUN pip install spotdl

RUN apt-get -y update
RUN apt-get install -y ffmpeg

CMD ["spotdl"]
