-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2020-11-16
-- Description:	Inserisce modifica o rimuove un attributo del referto
-- =============================================
CREATE PROCEDURE [dbo].[RefertoAttributoAggiorna]
(
 @IdReferto uniqueidentifier
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
		DELETE FROM  [store].[RefertiAttributi]
		WHERE [IdRefertiBase] = @IdReferto
			AND [DataPartizione] = @DataPartizione
			AND [Nome] = @AttribNome

	END ELSE BEGIN
		--
		-- Modifica e se non trovato inserisce
		--
		UPDATE [store].[RefertiAttributi]
		SET [Valore] = @AttribValore
		WHERE [IdRefertiBase] = @IdReferto
			AND [DataPartizione] = @DataPartizione
			AND [Nome] = @AttribNome

		SELECT @err = @@ERROR, @row = @@ROWCOUNT
		IF @row = 0
		BEGIN
			INSERT [store].[RefertiAttributi]( [IdRefertiBase], [DataPartizione], [Nome], [Valore])
			VALUES (@IdReferto, @DataPartizione, @AttribNome, @AttribValore)
		END
	END

	RETURN @err
END