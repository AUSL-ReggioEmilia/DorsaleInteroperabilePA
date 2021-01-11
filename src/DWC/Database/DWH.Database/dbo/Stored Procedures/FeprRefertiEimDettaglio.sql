
CREATE PROCEDURE [dbo].[FeprRefertiEimDettaglio]
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
		Allegati.Descrizione as Commenti,
		Allegati.Posizione as PrestazionePosizione
	FROM		
		frontend.Referti AS Referti
		INNER JOIN store.Allegati AS Allegati
			ON Referti.ID = Allegati.IDRefertiBase
	WHERE 	
		Referti.ID = @IdRefertiBase


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprRefertiEimDettaglio] TO [ExecuteFrontEnd]
    AS [dbo];

