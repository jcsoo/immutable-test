FROM debian:jessie

EXPOSE 5000
RUN mkdir /app/ /app/bin/ /app/dist/
WORKDIR /app/
ADD ./bin/ bin/
ADD ./dist/ dist/
CMD ["bin/main"]