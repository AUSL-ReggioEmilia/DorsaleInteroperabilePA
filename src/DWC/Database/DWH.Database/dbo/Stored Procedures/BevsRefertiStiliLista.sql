
CREATE PROCEDURE [dbo].[BevsRefertiStiliLista]
	@Nome as varchar(64)=null,
	@Descrizione as varchar(50)=null
 AS
/*
Ritorna la lista degli Stili legati ai Referti
*/
SET NOCOUNT ON

SELECT   Id, Nome, Descrizione, Abilitato,Tipo,XsltTestata,XsltRighe
FROM         RefertiStili
WHERE (Descrizione like  @Descrizione + '%' or @Descrizione is null)
	AND (Nome like '' + @Nome + '%' or @Nome is null)
ORDER BY  Nome, Descrizione


SET NOCOUNT OFF

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsRefertiStiliLista] TO [ExecuteFrontEnd]
    AS [dbo];

