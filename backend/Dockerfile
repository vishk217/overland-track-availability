FROM mcr.microsoft.com/playwright/python:v1.56.0-jammy-amd64

WORKDIR /var/task

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY *.py ./

ENTRYPOINT ["/usr/local/bin/python", "-m", "awslambdaric"]
CMD ["lambda_function.lambda_handler"]