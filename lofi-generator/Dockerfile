FROM python:3.9

RUN pip install --upgrade pip
RUN pip install moviepy

RUN apt-get -y update
RUN apt-get install -y ffmpeg
RUN apt-get install -y sox

COPY . .
RUN chmod a+x run.sh

CMD ["./run.sh"]
