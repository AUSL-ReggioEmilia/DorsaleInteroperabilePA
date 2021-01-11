
CREATE PROCEDURE [dbo].[FeAdminRefertoAllegatiLista]
	@IdReferto as uniqueidentifier
 AS
/*
Ritorna il dettaglio del referto

MODIFICA SANDRO 2015-08-19: Usa store.Allegati invece si dbo.AllegatiBase. Ha tutti i record e gestisce MimeDataCompresso
*/
BEGIN

	SET NOCOUNT ON
	--
	-- @IdReferto obbligatorio
	--
	IF @IdReferto IS NULL
		RAISERROR ('Error @IdReferto non può essere nullo!', 16 ,1 )
 	--
	-- Query del dettaglio
	--
	SELECT ab.ID,
			ab.IdRefertiBase,
			ab.IdEsterno,
			ab.DataInserimento,
			ab.DataModifica,
			ab.DataFile,
			ab.MimeType,
			ab.NomeFile,
			ab.Descrizione,
			ab.Posizione,
			ISNULL(ab.StatoDescrizione , '') + ISNULL(' (' + ab.StatoCodice + ')', '')	AS Stato

	FROM [store].[Allegati] AS ab
		WHERE ab.IdRefertiBase = @IdReferto
  
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeAdminRefertoAllegatiLista] TO [ExecuteFrontEnd]
    AS [dbo];

