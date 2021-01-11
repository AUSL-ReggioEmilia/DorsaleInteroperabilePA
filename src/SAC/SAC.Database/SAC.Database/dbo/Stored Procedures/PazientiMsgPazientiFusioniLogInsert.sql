-- =============================================
-- Author:		Ettore
-- Create date: 2015-09-18
-- Description:	Utilizzata dalla data access per creare un log delle fusioni che non possono essere eseguite
-- =============================================
CREATE PROCEDURE [dbo].[PazientiMsgPazientiFusioniLogInsert]
(
   @Utente varchar(64)
   , @IdPaziente uniqueidentifier
   , @Provenienza varchar(16)
   , @IdProvenienza varchar(64)
   , @Cognome varchar(64)
   , @Nome varchar(64)
   , @DataNascita datetime
   , @CodiceFiscale varchar(16)
   , @IdPazienteFuso uniqueidentifier
   , @ProvenienzaFuso varchar(16)
   , @IdProvenienzaFuso varchar(64)
   , @CognomeFuso varchar(64)
   , @NomeFuso varchar(64)
   , @DataNascitaFuso datetime
   , @CodiceFiscaleFuso varchar(16)
   , @Motivo varchar(4000)
)
AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO dbo.PazientiFusioniLog
	(
		DataInserimento
		,Utente
		,IdPaziente
		,Provenienza
		,IdProvenienza
		,Cognome
		,Nome
		,DataNascita
		,CodiceFiscale
		,IdPazienteFuso
		,ProvenienzaFuso
		,IdProvenienzaFuso
		,CognomeFuso
		,NomeFuso
		,DataNascitaFuso
		,CodiceFiscaleFuso
		,Motivo
	)
     VALUES    
	(
		GETDATE()
		, @Utente 
		, @IdPaziente 
		, @Provenienza
		, @IdProvenienza
		, @Cognome
		, @Nome
		, @DataNascita
		, @CodiceFiscale
		, @IdPazienteFuso
		, @ProvenienzaFuso
		, @IdProvenienzaFuso
		, @CognomeFuso
		, @NomeFuso
		, @DataNascitaFuso
		, @CodiceFiscaleFuso
		, @Motivo
	)
	
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgPazientiFusioniLogInsert] TO [DataAccessDll]
    AS [dbo];

