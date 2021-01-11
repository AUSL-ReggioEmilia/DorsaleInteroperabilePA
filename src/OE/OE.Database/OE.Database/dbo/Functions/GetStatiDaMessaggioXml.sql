
CREATE FUNCTION GetStatiDaMessaggioXml
(	
	@XmlPrestazioni as xml
)
RETURNS TABLE 
AS
RETURN 

WITH XMLNAMESPACES(DEFAULT 'http://schemas.progel.it/BT/OE/DataAccess/StatoParameter/1.1', 'http://schemas.progel.it/BT/OE/QueueTypes/1.1' as a)
SELECT DISTINCT
    X.z.value('a:StatoOrderEntry[1]', 'VARCHAR(max)')  as StatoOrderEntry
FROM 
    @XmlPrestazioni.nodes('/StatoParameter/StatoQueue/a:Testata/a:RigheErogate/a:RigaErogata') AS X(z)

