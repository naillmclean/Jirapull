FROM buildpack-deps:jessie

# remove several traces of debian python
RUN apt-get purge -y python.*

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# gpg: key F73C700D: public key "Larry Hastings <larry@hastings.org>" imported
ENV GPG_KEY 97FC712E4C024BBEA48A61ED3A5CA953F73C700D

ENV PYTHON_VERSION 3.5.2

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 8.1.2

RUN set -ex \
	&& curl -fSL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" -o python.tar.xz \
	&& curl -fSL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" -o python.tar.xz.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
	&& rm -r "$GNUPGHOME" python.tar.xz.asc \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz \
	\
	&& cd /usr/src/python \
	&& ./configure --enable-shared --enable-unicode=ucs4 \
	&& make -j$(nproc) \
	&& make install \
	&& ldconfig \
	&& pip3 install --no-cache-dir --upgrade pip==$PYTHON_PIP_VERSION \
	&& [ "$(pip list | awk -F '[ ()]+' '$1 == "pip" { print $2; exit }')" = "$PYTHON_PIP_VERSION" ] \
	&& find /usr/local -depth \
		\( \
		    \( -type d -a -name test -o -name tests \) \
		    -o \
		    \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
		\) -exec rm -rf '{}' + \
	&& rm -rf /usr/src/python ~/.cache

# make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
	&& ln -s easy_install-3.5 easy_install \
	&& ln -s idle3 idle \
	&& ln -s pydoc3 pydoc \
	&& ln -s python3 python \
	&& ln -s python3-config python-config

# Install Jira Library
RUN pip install jira

# Install qaautoapp
RUN mkdir -p /home/qaautoapp
COPY jiraimportapp.py /home/qaautoapp
COPY jiraquerysettings.py /home/qaautoapp
COPY jirasettings.py /home/qaautoapp
RUN chmod +x /home/qaautoapp/jiraimportapp.py \
    && chmod +x /home/qaautoapp/jirasettings.py \
    && chmod +x /home/qaautoapp/jiraquerysettings.py

# Install cron and rsyslog
RUN apt-get update && apt-get -y install cron rsyslog

# COPY crontab file in the cron directory
COPY crontab /etc/cron.d/cust-cron

# Give execution rights on the cron job
# and create log file to be able to run tail
RUN touch /var/log/cron.log \
    && chmod 0644 /etc/cron.d/cust-cron \
  #  && crontab /etc/cron.d/cust-cron \
	&& sed -i -e 's/#cron./cron./g' /etc/rsyslog.conf \
    && sed -i '/session required pam_loginuid.so/c\#session required pam_loginuid.so' /etc/pam.d/cron


#  Run the command on container startup
ADD start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh 

# expose src folder to allow mapping to host machine
VOLUME ["/usr/local/src"]

#CMD ["/bin/bash"]
CMD bash -C '/usr/local/bin/start.sh';'bash'

