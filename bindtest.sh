az group create -l northeurope -n 'groupWithAppServicePlan'
az group create -l northeurope -n 'groupWithWebAppAndCert'

az appservice plan create -n "appServicePlanBindTest" -g "groupWithAppServicePlan" --sku "S1" -l northeurope

az webapp config ssl upload --certificate-file testcert.pfx --certificate-password "test1234" --name "webAppWithCertInSameRg" -g "groupWithWebAppAndCert"

thumbprint=$(az webapp config ssl upload \
    --name webAppWithCertInSameRg \
    --resource-group groupWithWebAppAndCert \
    --certificate-file testcert.pfx \
    --certificate-password test1234 \
    --query thumbprint \
    --output tsv)

echo "found cert with thumbprint: $thumbprint"
echo "testing bind with following command /n az webapp config ssl bind --certificate-thumbprint $thumbprint --ssl-type SNI --name 'webAppWithCertInSameRg' -g 'groupWithWebAppAndCert'az webapp config ssl bind --certificate-thumbprint $thumbprint --ssl-type SNI --name 'webAppWithCertInSameRg' -g 'groupWithWebAppAndCert'"

az webapp config ssl bind --certificate-thumbprint $thumbprint --ssl-type SNI --name "webAppWithCertInSameRg" -g "groupWithWebAppAndCert"