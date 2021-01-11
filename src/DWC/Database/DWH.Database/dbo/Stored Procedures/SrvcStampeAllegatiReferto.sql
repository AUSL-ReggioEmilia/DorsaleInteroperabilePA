
CREATE PROCEDURE [dbo].[SrvcStampeAllegatiReferto] 
(
	@IdReferto uniqueidentifier,
	@MimeType varchar(50)
)
AS
BEGIN
/*

	MODIFICA ETTORE 2015-07-02: 
		Utilizzo la vista store.referti e store.allegati tanto questa chiamata la fa il servizio con un IdReferto processabile

*/
	SET NOCOUNT ON

	SELECT
		   Allegati.Id
		  ,Allegati.IdEsterno
		  ,Allegati.DataInserimento
		  ,Allegati.DataModifica
		  ,Allegati.DataFile
		  ,Allegati.MimeType
		  ,Allegati.MimeData
		  ,Allegati.NomeFile
		  ,Allegati.Descrizione
		  ,Allegati.Posizione
		  ,Allegati.StatoCodice
		  ,Allegati.StatoDescrizione
		  ,Referti.IdEsterno AS IdEsternoReferto
	FROM 
		store.Allegati AS Allegati
		INNER JOIN store.Referti AS Referti
			ON Allegati.IdRefertiBase = Referti .Id
	WHERE 
		Allegati.IdRefertiBase = @IdReferto
		AND (Allegati.MimeType = @MimeType OR @MimeType IS NULL)

END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SrvcStampeAllegatiReferto] TO [ExecuteService]
    AS [dbo];

