FROM python:3.8-slim 
WORKDIR /devops_app/devops_app
COPY ./devops_app /devops_app/devops_app/
RUN pip install -r requirements.txt
ENTRYPOINT [ "python" ]
CMD [ "devops_app.py" ]