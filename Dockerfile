FROM tiangolo/meinheld-gunicorn:python3.7-alpine3.8

ENV BEANCOUNT_FILE /bean/main.bean
ENV APP_MODULE management.wsgi
COPY requirements.txt /app
RUN rm main.py && \
    apk add --update --no-cache  --virtual .build-deps gcc libc-dev libxml2-dev python-dev libxml2 libxslt-dev && \
    pip install --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt && \
    apk del .build-deps

ENV USERNAME admin
ENV PASSWORD 123456

COPY . /app
COPY docker/prestart.sh /app/prestart.sh
RUN yes | python3 manage.py collectstatic && \
    sed -i 's/DEBUG = True/DEBUG = False/g' management/settings.py

