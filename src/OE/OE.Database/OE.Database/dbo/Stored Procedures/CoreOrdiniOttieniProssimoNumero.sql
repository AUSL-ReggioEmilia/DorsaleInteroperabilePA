-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-01-29
-- Description:	Ritorna prossimo numero libero per anno
-- =============================================
CREATE PROCEDURE [dbo].[CoreOrdiniOttieniProssimoNumero]
 @Anno AS INT = NULL
,@Numero AS INT OUTPUT
AS
BEGIN

DECLARE @RetTable TABLE(Numero INT)

	SET NOCOUNT ON;

	BEGIN TRY

		IF @Anno IS NULL
			SET @Anno = DATEPART(YEAR, GETDATE())

		SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		BEGIN TRAN

		-- Provo ad aggiornare
		UPDATE dbo.OrdiniSequenza
		SET Numero = Numero + 1, Data = GETUTCDATE()
		OUTPUT inserted.Numero INTO @RetTable
		WHERE Anno = @Anno

		-- Se non c'è inserisco
		IF NOT EXISTS (SELECT * FROM @RetTable)
		BEGIN
			-- Legge l'ultimo dalle testate
		    SELECT @Numero = ISNULL(MAX(Numero) + 1, 1)
			FROM OrdiniTestate WITH(NOLOCK)
			WHERE Anno = @Anno

			-- Salva per il prossimo
			INSERT INTO dbo.OrdiniSequenza (Anno, Numero, Data)
			OUTPUT inserted.Numero INTO @RetTable
			VALUES (@Anno, @Numero, GETUTCDATE())
		END

		-- Ritorno come parametro di OUTPUT
		SELECT @Numero = Numero FROM @RetTable

		COMMIT
		
		RETURN 0
	END TRY
	BEGIN CATCH
		ROLLBACK

		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)

		RETURN 1
	END CATCH
END
