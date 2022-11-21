FROM python

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm-256color
ENV LUV_HEADERS_FILE /southwest_headers.json
RUN ln -sf /usr/share/zoneinfo/EST /etc/localtime

# Install tools
RUN apt update -y && apt upgrade -y && apt autoremove -y && apt autoclean && apt-get install --fix-broken -y
RUN apt install -y wget vim at git unzip ruby ruby-dev gem

# Southwest header update
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt install -y ./google-chrome-stable_current_amd64.deb
RUN git clone https://github.com/wwilson83/southwest-headers
RUN wget https://chromedriver.storage.googleapis.com/107.0.5304.62/chromedriver_linux64.zip && unzip chromedriver_linux64.zip
RUN pip install -r /southwest-headers/requirements.txt
RUN perl -pi -e 's/pos_/dog_/g' ./chromedriver
RUN python /southwest-headers/southwest-headers.py /southwest_headers.json
RUN echo '0 */2 * * * env/bin/python southwest-headers.py /southwest_headers.json' >> mycron

#install new cron file
RUN crontab mycron
RUN rm mycron
RUN systemctl enable atd
Run service atd start

# Southwest auto checkin
#RUN export LUV_HEADERS_FILE=/southwest_headers.json
RUN git clone https://github.com/wwilson83/southwest-checkin.git
RUN cd southwest-checkin
RUN gem install autoluv


# Update DB and clean'up!

RUN apt-get autoremove -y
RUN apt-get clean
