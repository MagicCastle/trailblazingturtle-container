FROM python:3.9-slim-bullseye as backend-build-stage

RUN apt-get update && \
    apt-get install --no-install-recommends -y curl git gcc linux-libc-dev libc6-dev unzip libmariadb-dev libldap2-dev libsasl2-dev gettext

ENV TBT_VERSION=1.0.2
#RUN curl -L https://github.com/guilbaults/TrailblazingTurtle/archive/refs/tags/v${TBT_VERSION}.tar.gz -o tbt.tar.gz && \
RUN curl -L -O https://github.com/cmd-ntrf/TrailblazingTurtle/archive/refs/heads/base_dn.zip && \
    unzip base_dn.zip && \
    mv TrailblazingTurtle-base_dn /tbt

RUN pip install --upgrade pip
RUN pip install -r /tbt/requirements.txt
RUN pip install https://github.com/88Ocelot/django-freeipa-auth/archive/d77df67c03a5af5923116afa2f4280b8264b4b5b.zip

RUN /tbt/manage.py collectstatic --noinput
RUN /tbt/manage.py compilemessages
RUN cp /tbt/example/local.py /tbt/userportal/local.py

WORKDIR /tbt
CMD gunicorn --bind :8001 --workers 1 --timeout 90 userportal.wsgi
