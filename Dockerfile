FROM buildpack-deps:jessie
MAINTAINER Naill Mclean <naill_mclean@hotmail.com>
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

# Install Python Jira
RUN pip install jira schedule

# Install jirapullapp
RUN mkdir -p /home/jirapullapp
COPY jirapull.py /home/jirapullapp
COPY jirapull_db.py /home/jirapullapp
COPY jiraquerysettings /home/jirapullapp
COPY jirasettings /home/jirapullapp
COPY oraclesettings /home/jirapullapp
COPY jirapull_output.py /home/jirapullapp
COPY jirapull_encoding.py /home/jirapullapp

RUN chmod +x /home/jirapullapp/jirapull.py \
    && chmod +x /home/jirapullapp/jirapull_output.py \
	&& chmod +x /home/jirapullapp/jirapull_encoding.py \
    && chmod +x /home/jirapullapp/jirapull_db.py \
	&& touch /home/jirapullapp/__init__.py \
	&& apt-get update

#  add the the container startup script
ADD start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh 

# Optional add the Oracle Client, Oracle rpm files need to be downloaded and added to dockerfile folder
# download from [here](http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html) 

ADD . /tmp/
COPY ./oracle* /tmp/
RUN if [ -f /tmp/oracle*basic*.rpm ] ; then apt-get -y install libaio1 ; else echo "No Oracle rpm files, libaio1 install skipped" ; fi \
	&& if [ -f /tmp/oracle*basic*.rpm ] ; then apt-get -y install alien ; else echo "No Oracle rpm files, alien install skipped" ; fi \
	&& if [ -f /tmp/oracle*basic*.rpm ] ; then alien -k -d -i /tmp/*.rpm ; else echo "No Oracle rpm files, Oracle Client install skipped" ; fi \
	&& mkdir /usr/lib/oracle/12.1/client64/network/admin -p
	
COPY ./tnsnames.ora /usr/lib/oracle/12.1/client64/network/admin/tnsnames.ora

ENV ORACLE_HOME=/usr/lib/oracle/12.1/client64
ENV PATH=$PATH:$ORACLE_HOME/bin
ENV LD_LIBRARY_PATH=$ORACLE_HOME/lib
ENV TNS_ADMIN=$ORACLE_HOME/network/admin

RUN pip install cx_Oracle \
	&& apt-get autoclean

# expose src folder to allow mapping to host machine
VOLUME ["/usr/local/src"]

#CMD ["/bin/bash"]
CMD bash -C '/usr/local/bin/start.sh';'bash'