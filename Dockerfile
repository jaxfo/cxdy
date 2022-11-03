FROM alpine

COPY ./releases /releases
WORKDIR /releases

CMD sh entrypoint.sh