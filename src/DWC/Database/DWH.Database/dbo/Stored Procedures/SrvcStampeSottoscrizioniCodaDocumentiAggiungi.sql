
CREATE PROCEDURE [dbo].[SrvcStampeSottoscrizioniCodaDocumentiAggiungi]
(
	@IdStampeSottoscrizioniCoda uniqueidentifier
	,@HashDocumento image
	,@IdJob uniqueidentifier
	,@Stato INT
	,@DataSottomissione datetime
)
AS
BEGIN
	--
	-- Modifica Ettore 2013-04-22: per inserire mi assicuro che esista il record padre in StampeSottoscrizioniCoda
	-- (cosi si può cancellare una sottoscrizione e i suoi figli anche se il servizio la sta elaborando 
	-- senza creare errori di costrain)
	--
	INSERT INTO StampeSottoscrizioniDocumentiCoda
           (
           [IdStampeSottoscrizioniCoda]
           ,[HashDocumento]
           ,[IdJob]
           ,[DataSottomissione]
           ,[Stato]
			)
    SELECT 
		Id --@IdStampeSottoscrizioniCoda
        ,@HashDocumento
        ,@IdJob
        ,@DataSottomissione
        ,@Stato
    FROM 
		StampeSottoscrizioniCoda
	WHERE 
		Id = @IdStampeSottoscrizioniCoda
   
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SrvcStampeSottoscrizioniCodaDocumentiAggiungi] TO [ExecuteService]
    AS [dbo];

