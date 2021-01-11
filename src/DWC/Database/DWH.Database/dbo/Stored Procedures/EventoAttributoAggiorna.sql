
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2020-11-16
-- Description:	Inserisce modifica o rimuove un attributo dell'evento
-- =============================================
CREATE PROCEDURE [dbo].[EventoAttributoAggiorna]
(
 @IdEvento uniqueidentifier
,@DataPartizione datetime
,@AttribNome varchar(64)
,@AttribValore sql_variant
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @err INT = 0
	DECLARE @row INT = 0

	IF @AttribValore IS NULL
	BEGIN
		--
		-- Rimuove l'attributo
		--
		DELETE FROM  [store].[EventiAttributi]
		WHERE [IdEventiBase] = @IdEvento
			AND [DataPartizione] = @DataPartizione
			AND [Nome] = @AttribNome

	END ELSE BEGIN
		--
		-- Modifica e se non trovato inserisce
		--
		UPDATE [store].[EventiAttributi]
		SET [Valore] = @AttribValore
		WHERE [IdEventiBase] = @IdEvento
			AND [DataPartizione] = @DataPartizione
			AND [Nome] = @AttribNome

		SELECT @err = @@ERROR, @row = @@ROWCOUNT
		IF @row = 0
		BEGIN
			INSERT [store].[EventiAttributi]( [IdEventiBase], [DataPartizione], [Nome], [Valore])
			VALUES (@IdEvento, @DataPartizione, @AttribNome, @AttribValore)
		END
	END

	RETURN @err
END