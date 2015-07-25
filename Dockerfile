FROM ubuntu:14.04

RUN apt-get update && apt-get -y install python-ldap python-cairo python-django python-twisted python-django-tagging python-simplejson python-memcache python-pysqlite2 python-support python-pip gunicorn supervisor unzip

RUN pip install whisper
RUN pip install --install-option="--prefix=/var/lib/graphite" --install-option="--install-lib=/var/lib/graphite/lib" carbon
RUN pip install --install-option="--prefix=/var/lib/graphite" --install-option="--install-lib=/var/lib/graphite/webapp" graphite-web

# Consul
ADD https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip /tmp/consul.zip
RUN cd /bin && unzip /tmp/consul.zip && chmod +x /bin/consul && rm /tmp/consul.zip
ADD ./config /config/

ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD ./carbon.conf /var/lib/graphite/conf/carbon.conf

VOLUME /var/lib/graphite/storage/whisper
RUN cd /var/lib/graphite/webapp/graphite && python manage.py syncdb --noinput

ADD storage-schemas.conf /var/lib/graphite/conf/storage-schemas.conf

EXPOSE :2003
EXPOSE :2004
EXPOSE :7002
EXPOSE :8000

CMD ["/usr/bin/supervisord"]
