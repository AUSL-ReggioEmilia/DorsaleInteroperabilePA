



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Modify date: 2017-02-03 ETTORE: Gestione con Semaforo. Impostato TOP 1 per leggere un record alla volta
-- Modify date: 2017-03-02 ETTORE: Applicato pattern corretto per lettura da una coda: aggiunto WITH(READPAST, UPDLOCK), spostato il COMMIT dentro il TRY CATCH, tolto i WITH(NOLOCK)
-- =============================================
CREATE PROCEDURE  [dbo].[BtPazientiQueueOttieni]
AS
BEGIN
	SET NOCOUNT ON;

	--/////////////////////////////////////////////////////////////////////////////////////////////////////
	--   Nuovo gestione di accesso sequenziale tramite semaforo per uso con più host di BT
	--/////////////////////////////////////////////////////////////////////////////////////////////////////

	DECLARE @TimeOutReadSecond INT = 60
	--
	-- Controllo [HostBiztalk] con priorità di risposta
	--
	DECLARE @HostName VARCHAR(64) = CONVERT(VARCHAR(64), @@SPID)
	SELECT @HostName = RTRIM(hostname) FROM sys.sysprocesses WHERE spid = @@SPID

	DECLARE @HostNamePriority VARCHAR(64) = ''
	SELECT TOP 1 @HostNamePriority = [HostBiztalk]
	FROM [dbo].[PazientiQueueSemaforo] WITH(TABLOCKX)
	WHERE [DataLettura] > DATEADD( SECOND, @TimeOutReadSecond * -1, GETUTCDATE())
	ORDER BY [Primario] DESC, [HostBiztalk]

	--/////////////////////////////////////////////////////////////////////////////////////////////////////
	--
	-- Esegue solo sul PRIMARIO
	--

	IF @HostNamePriority = @HostName
	BEGIN

		SET TRANSACTION ISOLATION LEVEL READ COMMITTED
		BEGIN TRANSACTION
	
		BEGIN TRY

			declare @Errore int
			set @Errore = 0
		
			declare @tblTempPazientiQueue table(IdSeq uniqueidentifier)

			insert into @tblTempPazientiQueue
			select top 1 IdSeq   --<------------------- DEVE ESSERE TOP 1
			from PazientiQueue WITH (READPAST, UPDLOCK)
			order by DataOperazione, Utente

			SELECT PazientiQueue.DataOperazione
				  ,PazientiQueue.Utente
				  ,Operazione
				  ,Id
				  ,Tessera
				  ,Cognome
				  ,Nome
				  ,DataNascita
				  ,Sesso
				  ,ComuneNascitaCodice
				  ,NazionalitaCodice
				  ,ISNULL(CodiceFiscale, '0000000000000000') AS CodiceFiscale
				  ,DatiAnagmestici
				  ,MantenimentoPediatra
				  ,CapoFamiglia
				  ,Indigenza
				  ,CodiceTerminazione
				  ,DescrizioneTerminazione
				  ,ComuneResCodice
				  ,SubComuneRes
				  ,IndirizzoRes
				  ,LocalitaRes
				  ,CapRes
				  ,DataDecorrenzaRes
				  ,ComuneAslResCodice
				  ,CodiceAslRes
				  ,RegioneResCodice
				  ,ComuneDomCodice
				  ,SubComuneDom
				  ,IndirizzoDom
				  ,LocalitaDom
				  ,CapDom
				  ,PosizioneAss
				  ,RegioneAssCodice
				  ,ComuneAslAssCodice
				  ,CodiceAslAss
				  ,DataInizioAss
				  ,DataScadenzaAss
				  ,DataTerminazioneAss
				  ,DistrettoAmm
				  ,DistrettoTer
				  ,Ambito
				  ,CodiceMedicoDiBase
				  ,CodiceFiscaleMedicoDiBase
				  ,CognomeNomeMedicoDiBase
				  ,DistrettoMedicoDiBase
				  ,DataSceltaMedicoDiBase
				  ,ComuneRecapitoCodice
				  ,IndirizzoRecapito
				  ,LocalitaRecapito
				  ,Telefono1
				  ,Telefono2
				  ,Telefono3
				  ,CodiceSTP
				  ,DataInizioSTP
				  ,DataFineSTP
				  ,MotivoAnnulloSTP
				  ,FusioneId
				  ,FusioneCognome
				  ,FusioneNome
				  ,FusioneTessera
				  ,FusioneDataNascita
				  ,FusioneSesso
				  ,FusioneComuneNascitaCodice
				  ,FusioneNazionalitaCodice
				  ,FusioneCodiceFiscale
			FROM PazientiQueue inner join @tblTempPazientiQueue tblTemp on 
				PazientiQueue.IdSeq = tblTemp.IdSeq
			
			--
			-- Scrive nello storico (2011-08-11)
			--
			INSERT INTO [dbo].[PazientiQueue_Storico]
					   ([Utente]
					   ,[Operazione]
					   ,[DataOperazione]
					   ,[IdPaziente]
					   ,[Paziente])
			SELECT pq.[Utente]
					, pq.[Operazione]
					, pq.[DataOperazione]
					, pq.[Id] AS IdPaziente
					, CONVERT(XML, (SELECT Paziente.*
								FROM [PazientiQueue] AS Paziente
								WHERE Paziente.IdSeq = pq.IdSeq 
								FOR XML AUTO, ELEMENTS)) AS Paziente
			FROM [dbo].[PazientiQueue] AS pq
					inner join @tblTempPazientiQueue tblTemp on 
							pq.[IdSeq] = tblTemp.IdSeq
			--
			-- Rimuove dalla drop-table
			--
			delete PazientiQueue
			FROM PazientiQueue inner join @tblTempPazientiQueue tblTemp on 
				PazientiQueue.IdSeq = tblTemp.IdSeq
			--
			--
			--
			COMMIT

		END TRY
		BEGIN CATCH
			  declare @xact_state int
			  declare @msg nvarchar(2000)
			  select @xact_state = xact_state(), @msg = error_message()

			  IF @@TRANCOUNT > 0
			  BEGIN
				ROLLBACK TRANSACTION;
			  END

			  declare @report nvarchar(4000);
			  select @report = N'BtPazientiQueueOttieni. In catch: ' + @msg + N' xact_state:' + cast(@xact_state as nvarchar(5));
			  RAISERROR(@report, 16, 1)
			  print @report;
		END CATCH

		RETURN 1
	END ELSE BEGIN
		RETURN 0
	END 


END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BtPazientiQueueOttieni] TO [ExecuteBiztalk]
    AS [dbo];

