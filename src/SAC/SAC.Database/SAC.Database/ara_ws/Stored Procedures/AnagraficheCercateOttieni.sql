
-- =============================================
-- Author:		Ettore
-- Create date: 2020-10-20
-- Description:	Cerca per IdSAC e restituisce IdProvenienza(=IdARA) e la Risposta che verranno usate dal metodo WS di dettaglio 
--				per inserirli nel SAC e restituirli al chiamante
-- =============================================
CREATE PROCEDURE ara_ws.AnagraficheCercateOttieni
(
	@Identity VARCHAR(64)
	, @IdSac UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON;

	--
	-- Restituisco il record associato all'IdSac
	--
	SELECT 
		AC.IdSac
		, AC.IdProvenienza
		, AC.Risposta
	FROM 
		ara.AnagraficheCercate AS AC
	WHERE 
		AC.IdSac = @IdSac

END