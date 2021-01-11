
CREATE PROCEDURE [dbo].[FeprRefertiLettereDimissioniDettaglio]
(
	@IdRefertiBase UNIQUEIDENTIFIER
)
AS
/*
	MODIFICA ETTORE 2015-06-19: Utilizzo delle viste dello schema "frontend" e "store" 
*/
	SET NOCOUNT ON
	SELECT	
		Allegati.ID,
		--MODIFICA ETTORE 2012-09-10: traslo l'idpaziente nell'idpaziente attivo
		dbo.GetPazienteAttivoByIdSac(Referti.IDPaziente) AS IDPaziente,
		Referti.ID AS IdRefertiBase,
		Allegati.DataFile DataErogazione,
		Allegati.DataModifica,
		Allegati.NomeFile as NomeFile,
		REPLACE(Allegati.Descrizione, '(Mhtml)','') as Commenti,
		Allegati.Posizione as PrestazionePosizione
	FROM		
		frontend.Referti AS Referti 
		INNER JOIN store.Allegati AS Allegati 
			ON Referti.ID = Allegati.IDRefertiBase
	WHERE 	
		Referti.ID = @IdRefertiBase
		AND (Allegati.MimeType = 'message/rfc822' or Allegati.MimeType = 'application/pdf')


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprRefertiLettereDimissioniDettaglio] TO [ExecuteFrontEnd]
    AS [dbo];

