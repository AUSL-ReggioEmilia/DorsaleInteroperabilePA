

CREATE PROCEDURE [dbo].[FeAdminRefertoPrestazioniLista]
	@IdReferto as uniqueidentifier
 AS
/*
Ritorna il dettaglio del referto

MODIFICA SANDRO 2015-08-19
		Usa store.Allegati invece si dbo.AllegatiBase. Ha tutti i record e gestisce MimeDataCompresso

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
	SELECT pb.ID,
      pb.IdRefertiBase,
      pb.IdEsterno,
      pb.DataInserimento,
      pb.DataModifica,
      pb.DataErogazione,

      ISNULL(RIGHT('000' + CONVERT(VARCHAR (3), SezionePosizione), 3 ) + ' - ', '000 - ')
		+ ISNULL(pb.SezioneDescrizione + ' ', '') + ISNULL(' (' + pb.SezioneCodice + ')', '')
		AS Sezione,
 
      ISNULL(RIGHT('000' + CONVERT(VARCHAR (3), PrestazionePosizione), 3 ) + ' - ', '000 - ')
		+ ISNULL(pb.PrestazioneDescrizione + ' ', '') + ISNULL(' (' + pb.PrestazioneCodice + ')', '')
		AS Prestazione,

	  GravitaCodice,
	  GravitaDescrizione,

	  Risultato,
	  ValoriRiferimento,

	  Commenti

FROM store.[Prestazioni] AS pb
	WHERE pb.IdRefertiBase = @IdReferto
  
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeAdminRefertoPrestazioniLista] TO [ExecuteFrontEnd]
    AS [dbo];

