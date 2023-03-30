# az-appserv-sql-passwordless


```
az group create -n rgapp -l eastus
az appservice plan create -g rgapp -n planapp --is-linux --sku B1
az webapp create -g rgapp -p planapp -n appcustomsignin789 -r "DOTNETCORE:7.0" --https-only
az webapp config set -g rgapp -n appcustomsignin789 --always-on true
```

Add the required app settings (environment variables):

```
az webapp config appsettings set -g rgapp -n appcustomsignin789 \
        --settings WEBSITE_RUN_FROM_PACKAGE=1
```

```
bash build.sh
az webapp deployment source config-zip -g rgapp -n appcustomsignin789 --src ./bin/webapi.zip
```