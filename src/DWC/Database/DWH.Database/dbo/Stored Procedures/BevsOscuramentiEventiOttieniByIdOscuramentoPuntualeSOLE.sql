



-- =============================================
-- Author:      SimoneB.
-- Create date: 2017-10-16
-- Description: ottengo gli eventi "toccati" da un oscuramento.
--				@IdOscuramento deve essere <> NULL!!!
-- =============================================
CREATE PROCEDURE [dbo].[BevsOscuramentiEventiOttieniByIdOscuramentoPuntualeSOLE]
(
	@IdOscuramento UNIQUEIDENTIFIER
)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	IF @IdOscuramento IS NULL
	BEGIN
		RAISERROR('Il parametro @IdOscuramento è obbligatorio.', 16,1)
		RETURN
	END

  SELECT E.ID,
		E.IdEsterno,
		E.IdPaziente,
		E.DataInserimento,
		E.DataModifica,
		E.AziendaErogante,
		E.SistemaErogante,
		E.RepartoErogante,
		E.DataEvento,
		E.NumeroNosologico
		FROM store.Eventi AS E
		CROSS APPLY [dbo].[OttieniEventoOscuramenti](@IdOscuramento,'puntuali','SOLE',E.AziendaErogante,E.NumeroNosologico) AS EO
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsOscuramentiEventiOttieniByIdOscuramentoPuntualeSOLE] TO [ExecuteFrontEnd]
    AS [dbo];

