
CREATE PROCEDURE [dbo].[MaintenanceStorico_VersioniPerId]
  @IdOrdine UNIQUEIDENTIFIER
, @NR_GG_NO_HISTORY INT = 1
, @LOG BIT=0
AS
BEGIN
--MODIFICHE:
-- 2014-11-24 Sandro: Archivia le versioni della richiesta ID

	SET NOCOUNT ON
		
	BEGIN TRY
		BEGIN TRANSACTION
						
		-- Sync OrdiniVersioni - ok sandro
		INSERT INTO OrdiniVersioni_Storico (ID, DataInserimento, IDTicketInserimento, IDOrdineTestata, Tipo, StatoOrderEntry, DatiVersione, Data, DatiVersioneXmlCompresso, StatoCompressione)
			SELECT ID, DataInserimento, IDTicketInserimento, IDOrdineTestata, Tipo, StatoOrderEntry, DatiVersione, Data, DatiVersioneXmlCompresso, StatoCompressione
			FROM OrdiniVersioni 
			WHERE IDOrdineTestata = @IdOrdine
				AND DataInserimento <= DATEADD(dd,-@NR_GG_NO_HISTORY,GETDATE())

		-- Sync OrdiniErogatiVersioni - ok sandro
		INSERT INTO OrdiniErogatiVersioni_Storico (ID, DataInserimento, IDTicketInserimento, IDOrdineErogatoTestata, StatoOrderEntry, DatiVersione, DatiVersioneXmlCompresso, StatoCompressione)
			SELECT OV.ID, OV.DataInserimento, OV.IDTicketInserimento, OV.IDOrdineErogatoTestata, OV.StatoOrderEntry, OV.DatiVersione, OV.DatiVersioneXmlCompresso, OV.StatoCompressione
			FROM OrdiniErogatiVersioni OV INNER JOIN OrdiniErogatiTestate O
				ON OV.IDOrdineErogatoTestata = O.ID
			WHERE O.IDOrdineTestata = @IdOrdine
				AND O.DataInserimento <= DATEADD(dd,-@NR_GG_NO_HISTORY,GETDATE())
		
		-- Delete OrdiniErogatiVersioni
		DELETE FROM OrdiniErogatiVersioni
		FROM OrdiniErogatiVersioni OV INNER JOIN OrdiniErogatiTestate O ON OV.IDOrdineErogatoTestata = O.ID
		WHERE O.IDOrdineTestata = @IdOrdine
			AND O.DataInserimento <= DATEADD(dd,-@NR_GG_NO_HISTORY,GETDATE())

		-- Delete OrdiniVersioni
		DELETE FROM OrdiniVersioni WHERE IDOrdineTestata = @IdOrdine
			AND DataInserimento <= DATEADD(dd,-@NR_GG_NO_HISTORY,GETDATE())
				
		COMMIT
			
		-- Log
		IF @LOG = 1
		BEGIN
			BEGIN TRY
				INSERT INTO Log_Storico (IDOrdineTestata) VALUES (@IdOrdine)
			END TRY
			BEGIN CATCH
			END CATCH
		END	
		
		RETURN 0			
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 	
			ROLLBACK
			
		DECLARE @reason as varchar(max) = dbo.GetException()
		PRINT CHAR(9) + 'Errore: ' + @reason
								
		-- Log
		BEGIN TRY
			INSERT INTO Log_Storico (IDOrdineTestata, Errore) VALUES (@IdOrdine, @reason)
		END TRY
		BEGIN CATCH
		END CATCH
		
		RETURN 1			
	END CATCH
END
