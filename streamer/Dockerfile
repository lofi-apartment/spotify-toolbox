FROM ubuntu:24.04

RUN apt-get -y update
RUN apt-get install -y ffmpeg

COPY stream.sh .
RUN chmod a+x stream.sh

CMD ["bash", "-c", "./stream.sh"]
