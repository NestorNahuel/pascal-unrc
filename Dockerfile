FROM freepascal/fpc:3.2.2-focal-full

WORKDIR /app

COPY . /app/

RUN fpc proyecto.pas

CMD ["./proyecto"]
