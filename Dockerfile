FROM nowox/latex:1.0

RUN apt-get update
RUN apt-get install -y git wget
RUN apt-get install -y librsvg2-bin
RUN apt-get install -y python3 python3-pip python3-sphinx
RUN rm -rf /var/lib/apt/lists/*

RUN pip3 install sphinxcontrib-svg2pdfconverter
RUN pip3 install sphinx-heigvd-theme
