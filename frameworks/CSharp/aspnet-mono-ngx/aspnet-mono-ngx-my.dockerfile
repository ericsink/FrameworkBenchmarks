FROM mono:5.12.0.226
RUN apt update -yqq && apt install -yqq nginx wget mono-fastcgi-server

WORKDIR /aspnet-mono-ngx
COPY src src
COPY nginx.conf nginx.conf
COPY run.sh run.sh

RUN msbuild src/Benchmarks.build.proj /t:Clean
RUN msbuild src/Benchmarks.build.proj /t:Build /p:Configuration=Release

CMD bash run.sh
