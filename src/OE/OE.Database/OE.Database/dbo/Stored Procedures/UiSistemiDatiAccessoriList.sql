


CREATE PROCEDURE [dbo].[UiSistemiDatiAccessoriList]
@idSistema as uniqueidentifier
AS
BEGIN
SET NOCOUNT ON

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 5000 [Codice]     
      ,ISNULL([Descrizione],'') + CASE WHEN das.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END AS Descrizione
      ,[Etichetta] + + CASE WHEN das.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END AS Etichetta
      ,[Tipo]

  FROM [dbo].[DatiAccessori] da left join DatiAccessoriSistemi das on da.Codice = das.CodiceDatoAccessorio
  where das.IDSistema = @idSistema


SET NOCOUNT OFF
END







GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiSistemiDatiAccessoriList] TO [DataAccessUi]
    AS [dbo];

