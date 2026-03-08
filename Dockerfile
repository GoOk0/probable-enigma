FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV KEEP_ALIVE=true
ENV ROOT_PASSWORD=Bisam

WORKDIR /app

COPY setup.sh .
RUN chmod +x setup.sh

CMD ["bash", "setup.sh"]
