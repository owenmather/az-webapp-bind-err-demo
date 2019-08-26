MyWebapp=MyWebapp2139102312
echo "Creating resource groups. . ."
echo
az group create -l northeurope -n 'AspRG' --output none
az group create -l northeurope -n 'WebappRG' --output none

echo  "Creating app service plan MyASP. . ."
planId=$(az appservice plan create -n "MyASP" -g "AspRG" --sku "S1" -l northeurope --query id)
echo  "Created with id: $planId"
echo

echo  "Creating webapp $MyWebapp. . ."
webappId=$(eval `echo az webapp create -g WebappRG -p $planId -n  $MyWebapp --query id`)
echo  "Created webapp with id: $webappId \n"
echo

echo "Uploading pfx cert. . ."
az webapp config ssl upload --certificate-file testcert.pfx --certificate-password "test1234" --name "$MyWebapp" -g "WebappRG" --output none
echo
echo "Retrieving thumbprint. . ."
thumbprint=$(az webapp config ssl upload \
    --name "$MyWebapp" \
    --resource-group WebappRG \
    --certificate-file testcert.pfx \
    --certificate-password test1234 \
    --query thumbprint \
    --output tsv)

echo  "found cert with thumbprint: $thumbprint"
echo
echo "Attempting to bind webapp to pfx cert in seperate rg to asp.."
echo
az webapp config ssl bind --certificate-thumbprint $thumbprint --ssl-type SNI --name "$MyWebapp" -g "WebappRG"
