# App Services passwordless SQL Database connection

Full demonstration of how to connect from App Service via System-Assigned identity to Azure SQL Database. Guidelines used from [this article](https://learn.microsoft.com/en-us/azure/app-service/tutorial-connect-msi-azure-database?tabs=sqldatabase%2Csystemassigned%2Cnetfx%2Cwindowsclient).


Create the base resources:

```sh
# Resource Group
az group create -n rgapp -l eastus

# File share for Cloud Shell to assign the identity later - not needed if you already have one
az storage account create -n stpassless789cloudshell -g rgapp -l eastus --sku Standard_LRS
az storage share create -n cloudshell --account-name stpassless789cloudshell
```

Create the App Service admin user:

```sh
az ad user create --display-name appservadmin --password P4ssw0rd789 --user-principal-name appservadmin@<yourdomain>
```

Create SQL Database:

```
az sql server create -g rgapp -n sqlspassworldless789 -l eastus --admin-user sqladmin --admin-password P4ssw0rd789
az sql server firewall-rule create -g rgapp -s sqlspassworldless789 -n AllowAll --start-ip-address 0.0.0.0 --end-ip-address 255.255.255.0
az sql db create -g rgapp -s sqlspassworldless789 -n sqldbpassworldless789 --sample-name AdventureWorksLT --edition Basic --capacity 5
```

Add the AD admin previously created to the SQL Database server

```
az sql server ad-admin create -g rgapp -s sqlspassworldless789 --display-name ADMIN --object-id <id>
```

Create the App Service:

```
az appservice plan create -g rgapp -n planapp --is-linux --sku B1
az webapp create -g rgapp -p planapp -n apppassworldless789 -r "DOTNETCORE:7.0" --https-only
az webapp config set -g rgapp -n apppassworldless789 --always-on true
```

Assign the system identity:

```
az webapp identity assign -g rgapp -n apppassworldless789
```

Connect to the SQL Server using Cloud Shell and create the properties:

```
sqlcmd -S sqlspassworldless789.database.windows.net -d sqldbpassworldless789 -U <aad-user-name> -P "<aad-password>" -G -l 30

CREATE USER apppassworldless789 FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER apppassworldless789;
ALTER ROLE db_datawriter ADD MEMBER apppassworldless789;
ALTER ROLE db_ddladmin ADD MEMBER apppassworldless789;
GO
```


Add the required app settings (environment variables):

```
az webapp config appsettings set -g rgapp -n apppassworldless789 \
        --settings WEBSITE_RUN_FROM_PACKAGE=1
```

Build and deploy the ASP.NET Core application:

```
bash build.sh
az webapp deployment source config-zip -g rgapp -n apppassworldless789 --src ./bin/webapi.zip
```

Once ready, call the `/api/icecream` endpoint.
