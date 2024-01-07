FROM pierrezemb/gostatic:latest
ADD public /srv/http
ENTRYPOINT ["/goStatic"]
CMD [ "-enable-health" ]