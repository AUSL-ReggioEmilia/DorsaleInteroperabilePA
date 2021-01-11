-- =============================================
-- Author:		Ettore
-- Create date: 2016-07-18
-- Description:	Restituisce 1 se la provenienza può essere fusa in automatica
--				(Creata per la gestione delle anagrafiche HPV che non devono essere fuse in automatica)
-- =============================================
CREATE FUNCTION IsAnagraficaDaFondereAutomaticamente
(
	@Provenienza VARCHAR(16)
)
RETURNS BIT
AS
BEGIN
	DECLARE @FusioneAutomatica BIT
	--
	-- Inizializzo
	--
	SET @FusioneAutomatica = 0
	SELECT @FusioneAutomatica = FusioneAutomatica FROM Provenienze WHERE Provenienza = @Provenienza
	--
	-- Restituisco
	--
	RETURN  @FusioneAutomatica 
END