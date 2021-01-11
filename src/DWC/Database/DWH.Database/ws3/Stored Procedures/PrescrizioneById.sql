
-- =============================================
-- Author:		Ettore
-- Create date: 2015-11-12
-- Description:	Restituisce le informazioni di testata relative alla prescrizione
-- =============================================
CREATE PROCEDURE [ws3].[PrescrizioneById]
(
	@IdToken			UNIQUEIDENTIFIER
	, @IdPrescrizione	UNIQUEIDENTIFIER
)
AS
BEGIN
/*
	Per ora viene passato @IdToken ma non viene utilizzato
*/
	SET NOCOUNT ON
	SELECT 
		Id
		, DataPartizione
		, IdEsterno
		, DataInserimento
		, DataModifica
		, IdPaziente
		
		, Cognome
		, Nome
		, CodiceFiscale
		, DataNascita
		, Sesso		
		, ComuneNascita
		, CodiceSanitario
		
		, StatoCodice
		, TipoPrescrizione
		, DataPrescrizione
		, NumeroPrescrizione
		, QuesitoDiagnostico
		, MedicoPrescrittoreCodiceFiscale
		, Attributi 
  FROM 
     ws3.Prescrizioni	
  WHERE Id = @IdPrescrizione
  RETURN @@ERROR
END