

-- =============================================
-- Author:		Simone B
-- Create date: 2019-06-13
-- Description:	Ricerca in dbo.DizionarioEsenzioni per codice e testo del dizionario esenzione
-- =============================================
CREATE PROCEDURE [pazienti_ws].[DizionariEsenzioniCerca]
(
	@MaxRecord INT,
	@Ordinamento VARCHAR(128),
	@Identity VARCHAR(64),
	@CodiceEsenzione VARCHAR(32),
	@TestoEsenzione VARCHAR(2048)
			
) WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
	-- CONTROLLO ACCESSO
	IF dbo.LeggePazientiPermessiLettura(@Identity) = 0
	BEGIN 
		EXEC PazientiEventiAccessoNegato @Identity, 0, 'DizionariEsenzioniCerca', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante PazientiByGeneralita!', 16, 1)
		RETURN
	END

	-- IMPOSTO '' PER L'ORDINAMENTO DI DEFAULT
	SET @Ordinamento = ISNULL(@Ordinamento,'')

	-- CERCO I DIZIONARI ESENZIONI
	SELECT TOP(@MaxRecord)
		   CodiceEsenzione
		  ,CodiceDiagnosi
		  ,Patologica
		  ,TestoEsenzione
		  ,DecodificaEsenzioneDiagnosi
	FROM dbo.DizionarioEsenzioni
	WHERE (CodiceEsenzione LIKE '%' + @CodiceEsenzione + '%' OR @CodiceEsenzione IS NULL)
		 AND (TestoEsenzione LIKE '%' + @TestoEsenzione + '%' OR @TestoEsenzione IS NULL)

END