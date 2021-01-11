


-- =============================================
-- Author:	Alessandro Nostini
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[MntRefertoCancellaPerId]
	 @Id uniqueidentifier
AS
BEGIN
/*
	Modifica Ettore 2013-04-05: tolto i riferimenti a RefertiLog
	Modificata SANDRO 2015-08-20: Usa VIEW store
	Modificata ETTORE 2016-12-12: Cancellazione anche da store.RefertiBaseRiferimenti

*/
	SET NOCOUNT ON;

	IF @Id IS NULL
	BEGIN
		RAISERROR('Il parametro @Id non può essere NULL!', 16, 1)
		RETURN 1
	END
	
	DECLARE @IdEsterno varchar(64) = NULL
	SET @IdEsterno = dbo.GetRefertiIdEsterno(@Id)
	
	IF @IdEsterno IS NULL
	BEGIN
		RAISERROR('Referto non trovato!', 16, 1)
		RETURN 1
	END

	BEGIN TRY
		BEGIN TRAN

		----------------------------------------------------------
		--  		Cancello tutto il referto
		-----------------------------------------------------------

		--ALLEGATI ATTRIB

		DELETE FROM [store].[AllegatiAttributi]
		WHERE IdAllegatiBase IN
			(
		SELECT ab.Id
		FROM [store].[AllegatiBase] ab WITH(NOLOCK)
		WHERE ab.IdRefertiBase = @Id
			)

		--ALLEGATI

		DELETE FROM [store].[AllegatiBase]
		WHERE IdRefertiBase = @Id

		-- PRESTAZIONI ATTRIB

		DELETE FROM [store].[PrestazioniAttributi]
		WHERE IdPrestazioniBase IN
			(
		SELECT ab.Id
		FROM [store].[PrestazioniBase] ab WITH(NOLOCK)
		WHERE ab.IdRefertiBase = @Id
			)

		-- PRESTAZIONI

		DELETE FROM [store].[PrestazioniBase]
		WHERE IdRefertiBase = @Id


		-- REFERTI ATTRIB

		DELETE FROM [store].[RefertiAttributi]
		WHERE IdRefertiBase = @Id

		-- REFERTIBASERIFERIMENTI

		DELETE FROM store.RefertiBaseRiferimenti
		WHERE IdRefertiBase = @Id

		-- REFERTI

		DELETE FROM [store].[RefertiBase]
		WHERE Id = @Id
		
		COMMIT
		RETURN 0
	END TRY
	BEGIN CATCH
		-- Errore
		IF @@TRANCOUNT > 0
			ROLLBACK

		RETURN 1
	END CATCH
	
END

