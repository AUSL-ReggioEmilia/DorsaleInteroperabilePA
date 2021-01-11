
CREATE PROCEDURE [dbo].[UiPrestazioniDatiAccessoriList]
@idPrestazione as uniqueidentifier
AS
BEGIN
SET NOCOUNT ON

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 5000 [Codice]      
      ,ISNULL([Descrizione],'') + CASE WHEN dap.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END AS Descrizione
      ,[Etichetta] + CASE WHEN dap.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END AS Etichetta
      ,[Tipo]     
  FROM [dbo].[DatiAccessori] da LEFT JOIN DatiAccessoriPrestazioni dap ON da.Codice = dap.CodiceDatoAccessorio
  WHERE dap.IDPrestazione = @idPrestazione


SET NOCOUNT OFF
END








GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiPrestazioniDatiAccessoriList] TO [DataAccessUi]
    AS [dbo];

