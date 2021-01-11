-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-03-01
-- Modify date: 2013-10-10 SANDRO: Nuovo campo NomeDatoAggiuntivo
-- Modify date: 2016-08-25 SANDRO Nuovo dato ConcatenaNomeUguale
-- Description:	Seleziona un dato accessorio
-- =============================================
CREATE PROCEDURE [dbo].[CoreDatiAccessoriSelect2]
	@Codice varchar(64)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT
			  Codice
			, DataInserimento
			, DataModifica
			, CONVERT(uniqueidentifier, '00000000-0000-0000-0000-000000000000') AS IDTicketInserimento
			, CONVERT(uniqueidentifier, '00000000-0000-0000-0000-000000000000') AS IDTicketModifica
			, Descrizione
			, Etichetta
			, Tipo
			, Obbligatorio
			, Ripetibile
			, Valori
			, Ordinamento
			, Gruppo
			, ValidazioneRegex
			, ValidazioneMessaggio
			, Sistema
			, ValoreDefault
			, NomeDatoAggiuntivo
			, ConcatenaNomeUguale
		FROM 
			DatiAccessori
		WHERE 
			Codice = @Codice
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreDatiAccessoriSelect2] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreDatiAccessoriSelect2] TO [DataAccessWs]
    AS [dbo];

