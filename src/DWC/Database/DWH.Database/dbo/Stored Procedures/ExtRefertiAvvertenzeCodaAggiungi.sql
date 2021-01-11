
-- =============================================
-- Author:		ETTORE
-- Create date: 2020-05-25
-- Description:	Inserisce nella tabella RefertiAvvertenzeCoda i referti per i quali 
--				devono essere calcolate le "Avvertenze"
-- =============================================
CREATE PROCEDURE [dbo].[ExtRefertiAvvertenzeCodaAggiungi]
(
@IdReferto UNIQUEIDENTIFIER
,@AziendaErogante VARCHAR(16)
,@SistemaErogante VARCHAR(16)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	-- Leggo dalla tabella di configurazione "RefertiAvvertenze" se il sistema erogante è configurato per il calcolo delle avvertenze
	--
	IF EXISTS(SELECT * FROM dbo.RefertiAvvertenze WHERE AziendaErogante = @AziendaErogante AND SistemaErogante = @SistemaErogante)
	BEGIN
		INSERT INTO dbo.RefertiAvvertenzeCoda(IdReferto) 
		VALUES (@IdReferto)
	END

END