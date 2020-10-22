FROM python: 2.7.12
WORKDIR /usr/bin
RUN pip install numpy==1..1.1
RUN pip install ortools==7.3.7083

