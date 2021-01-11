CD "C:\Progetti\Commesse\DI\OE\OE.DataAccess\OE.Core\Schemi\Wcf"

svcutil.exe /dconly /tcv:Version35 /l:vb /o:SchemasDataContract.vb /n:"http://schemas.progel.it/OE/Types/1.1, Schemas.Wcf.BaseTypes" /n:"http://schemas.progel.it/WCF/OE/WsTypes/1.1, Schemas.Wcf.WsTypes" "oe-Types-Qualified.xsd" "oe-Ws-Qualified.xsd"
svcutil.exe /dconly /tcv:Version35 /l:vb /o:SchemasDataContract12.vb /n:"http://schemas.progel.it/OE/Types/1.2, Schemas.Wcf12.BaseTypes" /n:"http://schemas.progel.it/WCF/OE/WsTypes/1.2, Schemas.Wcf12.WsTypes" "oe-Types12-Qualified.xsd" "oe-Ws12-Qualified.xsd"
