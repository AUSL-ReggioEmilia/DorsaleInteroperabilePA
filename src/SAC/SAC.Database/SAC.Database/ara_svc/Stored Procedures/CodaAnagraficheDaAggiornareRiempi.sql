









-- =============================================
-- Author:		ETTORE
-- Create date: 2020-10-21
-- Description:	Legge dal SAC le anagrafiche ARA da aggiornare
--				1) Provenienza "ARA"  
--				2) DataModifica < DATEADD(day, -30, GETDATE())  --Importo i record non modificati negli ultimi 30 giorni
--				3) DataUltimoUtilizzo DESC
-- =============================================
CREATE PROCEDURE [ara_svc].[CodaAnagraficheDaAggiornareRiempi]
(
@MaxNumRecord INT
)
AS
BEGIN
	DECLARE @Provenienza VARCHAR(16)
	SET NOCOUNT ON;
	--
	-- Eseguo controlli fuori dalla transazione
	--
	SELECT @Provenienza = ValoreString FROM ara.Config WHERE Nome = 'Provenienza'
	IF ISNULL(@Provenienza, '') = '' 
	BEGIN
		RAISERROR('La @Provenienza per ARA non è valorizzata. Vedi tabella ara.Config.', 16, 1)
		RETURN
	END

	--
	-- Uso HINT per bloccare la tabella perchè l'inserimento sarà fatto da più istanze del servizio
	-- WITH(TABLOCK, HOLDLOCK) e WITH(TABLOCKX) sono equivalenti
	--
	BEGIN TRANSACTION 
	BEGIN TRY
		INSERT INTO ara_svc.CodaAnagraficheDaAggiornareInput WITH(TABLOCKX) 
			(DataInserimentoUtc, IdSac) 
		SELECT TOP (@MaxNumRecord)
			GETUTCDATE(), P.Id AS IdSac 
		FROM 
			Pazienti AS P
		WHERE 
			--Filtro per provenienza ARA
			Provenienza = @Provenienza 
			--Importo i record non modificati negli ultimi 30 giorni
			AND P.DataModifica < DATEADD(day, -30, GETDATE())
			AND NOT EXISTS (
				SELECT * FROM ara_svc.CodaAnagraficheDaAggiornareInput WHERE IdSac = P.Id
				)
		ORDER BY 
			P.DataUltimoUtilizzo DESC
		--
		--
		--
	
		COMMIT

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK
		--
		-- Rilancio eccezione al chiamante
		--
		;THROW

	END CATCH

END