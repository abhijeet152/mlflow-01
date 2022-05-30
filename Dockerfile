FROM python:3.7-slim-buster

# build variables.
ENV DEBIAN_FRONTEND noninteractive
ENV MLFLOW_SERVER_HOST 0.0.0.0
ENV MLFLOW_SERVER_DEFAULT_ARTIFACT_ROOT "wasbs://containermlflow@storageacmlflow.blob.core.windows.net"
#https://storageacmlflow.blob.core.windows.net/containermlflow
ENV AZURE_STORAGE_ACCESS_KEY "8KMv3HAkvdVjioX4hY67WsEEQqix45FlGJS4d8+9278jtr10Cjqk3WrXYrVqVeHDr9ntHAynXq1j+AStElaqQg=="
#ENV BACKEND_URI "mssql+pyodbc://mlflowadmin:P@ssw0rd@mlflowsql-server.database.windows.net:1433/mlflowdatabase?driver=ODBC+Driver+17+for+SQL+Server"
ENV BACKEND_URI "mssql+pymssql://mlflowadmin:P%40ssw0rd@mlflowsql-server.database.windows.net:1433/mlflowdatabase"
#ENV BACKEND_URI "sqlserver://mlflowsql-server.database.windows.net:1433;database=mlflowdatabase;user=mlflowadmin@mlflowsql-server;password=P@ssw0rd;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"
# install Microsoft SQL Server requirements.
ENV ACCEPT_EULA=Y
RUN apt-get update -y && apt-get update \
  && apt-get install -y --no-install-recommends curl gcc g++ gnupg unixodbc-dev

# Add SQL Server ODBC Driver 17 for Ubuntu 18.04
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
  && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends --allow-unauthenticated msodbcsql17 mssql-tools \
  && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile \
  && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

# Set the working directory to /
WORKDIR /

# Copy the directory contents into the container at /
COPY . /

RUN apt-get update
RUN pip install -r requirements.txt

# clean the install.
RUN apt-get -y clean
ENV PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python
#ENTRYPOINT ["./startup.sh"]
CMD mlflow server --backend-store-uri "$BACKEND_URI" --default-artifact-root "$MLFLOW_SERVER_DEFAULT_ARTIFACT_ROOT" --host 0.0.0.0
#CMD mlflow server --host 0.0.0.0
