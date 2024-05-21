# App Services passwordless SQL Database connection

App Service passwordless authentication to Azure SQL Database with Microsoft Entra authentication.

## Infrastructure

Copy the `.auto.tfvars` template file:

```sh
cp infra/config/template.tfvars infra/.auto.tfvars
```

Create the VM SSH keys:

```sh
mkdir infra/keys
ssh-keygen -f infra/keys/temp_key
chmod 600 infra/keys/temp_key
```

Create the infrastructure:

> [!NOTE]
> App Service health checks will show as unhealthy until the app is deployed, as the health check path is configured to be at `/healthz`.

```sh
terraform -chdir="infra" init
terraform -chdir="infra" apply -auto-approve
```

## Permissions: App Service

Whe using **System-Assigned** managed identity, the configuration uses the App Service **name** as login.

### SQL Server

Create the login from an external provider:

```sql
USE master
CREATE LOGIN [app-contoso-8hkgb] FROM EXTERNAL PROVIDER
GO
```

Check the server login:

```sql
SELECT name, type_desc, type, is_disabled 
FROM sys.server_principals
WHERE type_desc like 'external%'  
```

### SQL Database

Create the database user associated with the external login:

```sql
CREATE USER [app-contoso-8hkgb] FROM LOGIN [app-contoso-8hkgb]
GO
```

Check the database user:

```sql
SELECT name, type_desc, type 
FROM sys.database_principals 
WHERE type_desc like 'external%'
```

Add the necessary permissions to the user:

```sql
ALTER ROLE db_datareader ADD MEMBER [app-contoso-8hkgb];
ALTER ROLE db_datawriter ADD MEMBER [app-contoso-8hkgb];
ALTER ROLE db_ddladmin ADD MEMBER [app-contoso-8hkgb];
GO
```

## Deploy the application

Enter the application directory, then build and deploy the application:

```sh
bash build.sh
az webapp deploy -g rg-contoso-8hkgb -n app-contoso-8hkgb --type zip --src-path ./bin/webapi.zip
```

Once deployed, test the database connectivity:

```sh
curl <appservice>/api/icecream
```

## Database-level roles

When creating database users, SQL offers native [database-level roles][1]. Commands below are based off of [this][2] article.

Run it from the `master` database:

```sql
-- create SQL login in master database
CREATE LOGIN [USERNAME]
WITH PASSWORD = '*****';
```

Now, from the application database:

```sql
-- add database user for login [USERNAME]
CREATE USER [USERNAME]
FROM LOGIN [USERNAME]
WITH DEFAULT_SCHEMA=dbo;
```

Assign roles:

```sql
-- add user to database role(s)
ALTER ROLE db_ddladmin ADD MEMBER [USERNAME];
ALTER ROLE db_datawriter ADD MEMBER [USERNAME];
ALTER ROLE db_datareader ADD MEMBER [USERNAME];
```

User is ready. It is necessary to inform the database name during authentication.


## Clean-up

Delete the Azure resources:

```sh
terraform destroy -auto-approve
```

## Reference

- [Create and utilize Microsoft Entra server logins](https://learn.microsoft.com/en-us/azure/azure-sql/database/authentication-azure-ad-logins-tutorial?view=azuresql)
- [Connect to Azure databases from App Service without secrets using a managed identity](https://learn.microsoft.com/en-us/azure/app-service/tutorial-connect-msi-azure-database?tabs=sqldatabase%2Csystemassigned%2Cnetfx%2Cwindowsclient)


[1]: https://learn.microsoft.com/en-us/sql/relational-databases/security/authentication-access/database-level-roles
[2]: https://www.sqlnethub.com/blog/creating-azure-sql-database-logins-and-users/
