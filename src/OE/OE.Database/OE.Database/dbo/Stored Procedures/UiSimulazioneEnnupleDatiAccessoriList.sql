-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2017-02-23
-- Description:	Restituisce la lista dei DatiAccessori usabili dall'utente
-- Modified: 
-- =============================================
CREATE PROCEDURE [dbo].[UiSimulazioneEnnupleDatiAccessoriList]
	  @nomeUtente VARCHAR(64)
	, @giorno DATETIME
	, @idUnitaOperativa UNIQUEIDENTIFIER
	, @idSistemaRichiedente UNIQUEIDENTIFIER
	, @codiceRegime VARCHAR(16)
	, @codicePriorita VARCHAR(16)
	, @idStato TINYINT = NULL
	, @filtroCodiceDescrizione VARCHAR(256) = NULL
AS
BEGIN
	-- Imposta il primo giorno della settimana su un numero compreso tra 1 e 7.
	SET DATEFIRST 1

	SET NOCOUNT ON;

	BEGIN TRY
	
		SELECT Codice            
			,Descrizione       
			,Etichetta       
			,Tipo              
	
		FROM dbo.GetDatiAccessoriUsabili( @nomeUtente 
										, @idUnitaOperativa 
										, @idSistemaRichiedente 
										, @giorno 
										, @codiceRegime 
										, @codicePriorita 
										, @idStato 
										, @filtroCodiceDescrizione )

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiSimulazioneEnnupleDatiAccessoriList] TO [DataAccessUi]
    AS [dbo];

