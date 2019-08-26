echo "Creating resource groups. . ."
echo
az group create -l northeurope -n 'groupWithAppServicePlan' --output none
az group create -l northeurope -n 'groupWithWebAppAndCert' --output none

echo  "Creating app service plan appServicePlanBindTest. . ."
planId=$(az appservice plan create -n "appServicePlanBindTest" -g "groupWithAppServicePlan" --sku "S1" -l northeurope --query id)
echo  "Created with id: $planId"
echo

echo  "Creating webapp webAppWithCertInSameRg. . ."
webappId=$(eval `echo az webapp create -g groupWithWebAppAndCert -p $planId -n webAppWithCertInSameRg --query id`)
echo  "Created webapp with id: $webappId \n"
echo

echo "Uploading pfx cert. . ."
az webapp config ssl upload --certificate-file testcert.pfx --certificate-password "test1234" --name "webAppWithCertInSameRg" -g "groupWithWebAppAndCert" --output none
echo
echo "Retrieving thumbprint. . ."
thumbprint=$(az webapp config ssl upload \
    --name webAppWithCertInSameRg \
    --resource-group groupWithWebAppAndCert \
    --certificate-file testcert.pfx \
    --certificate-password test1234 \
    --query thumbprint \
    --output tsv)

echo  "found cert with thumbprint: $thumbprint"
echo
echo "Attempting to bind webapp to pfx cert in seperate rg to asp.."
echo
az webapp config ssl bind --certificate-thumbprint $thumbprint --ssl-type SNI --name "webAppWithCertInSameRg" -g "groupWithWebAppAndCert"
