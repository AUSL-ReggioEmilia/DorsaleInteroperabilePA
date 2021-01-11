
--
-- Author:		/
-- Description: /
-- Date:		/
-- Modify date: 2017-11-28 SimoneB: Restituisco il campo EtichettaCodiceDescrizione utilizzato per valorizzare il text delle dropdownlist di OE Admin.
--
CREATE PROCEDURE [dbo].[UiDatiAccessoriSelect]

AS
BEGIN
SET NOCOUNT ON

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 5000 [Codice]
      ,[DataInserimento]
      ,[DataModifica]
	  , CONVERT(uniqueidentifier, '00000000-0000-0000-0000-000000000000') AS IDTicketInserimento
	  , CONVERT(uniqueidentifier, '00000000-0000-0000-0000-000000000000') AS IDTicketModifica
	  ,[Descrizione]
      ,[Etichetta]
      ,[Tipo]
      ,[Obbligatorio]
      ,[Ripetibile]
      ,[Valori]
      ,[Ordinamento]
      ,[Gruppo]
      ,[ValidazioneRegex]
      ,[ValidazioneMessaggio]
      ,Sistema
      ,ValoreDefault
      ,NomeDatoAggiuntivo
	  ,[Codice] + ' (' +[Etichetta] + ')' AS EtichettaCodiceDescrizione
FROM [dbo].[DatiAccessori]
ORDER BY Etichetta


SET NOCOUNT OFF
END









GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiDatiAccessoriSelect] TO [DataAccessUi]
    AS [dbo];

