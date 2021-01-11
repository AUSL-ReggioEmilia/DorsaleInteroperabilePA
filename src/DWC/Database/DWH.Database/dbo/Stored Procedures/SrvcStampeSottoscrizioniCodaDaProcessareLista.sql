CREATE  PROCEDURE [dbo].[SrvcStampeSottoscrizioniCodaDaProcessareLista]
(
@IdStampeSottoscrizione uniqueidentifier
)
AS
BEGIN

	SET NOCOUNT ON;
	--
	-- Prelevo i record per i quali si deve mandare in stampa gli allegati
	-- Sono quelli per cui la data di sottomissione alla stampa è NULL e non hanno ERRORE
	--
	SELECT 
	   [Id]
	  ,[Ts]
      ,[DataInserimento]
      ,[DataModifica]
      ,[IdStampeSottoscrizioni]
      ,[IdReferto]
	  ,[DataModificaReferto]
      ,[Errore]
	  ,[DataSottomissione]
	  ,[CounterModificheReferto]
	FROM 
		StampeSottoscrizioniCoda
	WHERE
		(IdStampeSottoscrizioni = @IdStampeSottoscrizione)
		--non ancora sottomesso
		AND 
		(DataSottomissione IS NULL)
		-- e non ci sono errori
		AND 
		(ISNULL(Errore,'') = '')
	ORDER BY
		[DataInserimento]
	
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SrvcStampeSottoscrizioniCodaDaProcessareLista] TO [ExecuteService]
    AS [dbo];

