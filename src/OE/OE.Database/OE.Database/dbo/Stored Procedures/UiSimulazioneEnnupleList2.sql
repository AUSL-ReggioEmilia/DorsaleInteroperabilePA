-- =============================================
-- Author:		Stefano Piletti
-- Modify date: 2016-07-20
-- Modify date: 2018-02-19 La func GetPrestazioniRichiedibili2() richiede tre nuovi parametri
-- Description:	Restituisce la lista di prestazioni richiedibili dall'utente
-- Modified: 
-- =============================================
CREATE PROCEDURE [dbo].[UiSimulazioneEnnupleList2]
	  @nomeUtente VARCHAR(64)
	, @giorno DATETIME
	, @idUnitaOperativa UNIQUEIDENTIFIER
	, @idSistemaRichiedente UNIQUEIDENTIFIER
	, @codiceRegime VARCHAR(16)
	, @codicePriorita VARCHAR(16)
	, @idStato TINYINT = NULL
	, @prestazioneCodiceDescrizione VARCHAR(256) = NULL
    , @idSistemaErogante UNIQUEIDENTIFIER = NULL
AS
BEGIN
	-- Imposta il primo giorno della settimana su un numero compreso tra 1 e 7.
	SET DATEFIRST 1

	SET NOCOUNT ON;

	BEGIN TRY
	
		SELECT
		 ID                
		,Codice            
		,Descrizione       
		,Tipo              
		,IDSistemaErogante
		,CAST(1 AS BIT) AS Attivo 
	
		FROM dbo.GetPrestazioniRichiedibili2( @nomeUtente 
											, @idUnitaOperativa 
											, @idSistemaRichiedente 
											, @giorno 
											, @codiceRegime 
											, @codicePriorita 
											, @idStato 
											, @idSistemaErogante
											, @prestazioneCodiceDescrizione
											, NULL, 1, 1)
		WHERE
		 IDSistemaErogante=@idSistemaErogante

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiSimulazioneEnnupleList2] TO [DataAccessUi]
    AS [dbo];

