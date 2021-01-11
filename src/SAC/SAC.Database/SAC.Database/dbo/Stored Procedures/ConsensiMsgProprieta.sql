



-- =============================================
-- Author:		
-- Create date: 
-- Description:	restituisce i dati minimi del consenso per testarne la presenza
-- Modify date: 2020-01-21 ETTORE: Aggiunto gli HINT WITH(ROWLOCK, UPDLOCK, HOLDLOCK) per evitare duplicaione dei consensi
-- =============================================
CREATE PROCEDURE [dbo].[ConsensiMsgProprieta]
	  @Utente AS varchar(64)
	, @IdProvenienza AS varchar(64)
AS
BEGIN

DECLARE @Provenienza AS varchar(16)

	SET NOCOUNT ON;
	
	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------
	
	IF dbo.LeggeConsensiPermessiLettura(@Utente) = 0
	BEGIN
		EXEC ConsensiEventiAccessoNegato @Utente, 0, 'ConsensiMsgProprieta', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi!', 16, 1)
		RETURN 1002
	END

	---------------------------------------------------
	-- Calcolo provenienza da utente
	---------------------------------------------------

	SET @Provenienza = dbo.LeggeConsensiProvenienza(@Utente)

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT Consensi.Id
		, DataDisattivazione
		, Disattivato
		, Provenienza
		, IdProvenienza
		, IdPaziente

	FROM 
		--Consensi
		Consensi WITH(ROWLOCK, UPDLOCK, HOLDLOCK) 
	
	WHERE
			Provenienza = @Provenienza
		AND IdProvenienza = @IdProvenienza
		AND Disattivato = 0

END













GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiMsgProprieta] TO [DataAccessDll]
    AS [dbo];

