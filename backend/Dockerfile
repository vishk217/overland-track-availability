FROM mcr.microsoft.com/playwright/python:v1.56.0-jammy-arm64

WORKDIR /var/task

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY *.py ./

ENTRYPOINT ["python3", "-m", "awslambdaric"]
CMD ["lambda_function.lambda_handler"]