
-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2014-10-23
-- Modify date: 2014-11-04 SANDRO: Usa la nuova Func GetPrestazioniRichiedibili() per valutare l'accesso
-- Modify date: 2018-02-07 SANDRO: Problema saltuario di time-out invece che quanche sec di exec
--									Rimosso WITH RECOMPILE e aggiunto OPTION (RECOMPILE)
-- Modify date: 2018-06-19 SANDRO: Usa nuovo Func (già provata in ByIdGruppo)
--
-- Description:	Ritorna un elenco di prestazioni (con accesso) di un gruppo
-- =============================================
CREATE PROCEDURE [dbo].[CorePrestazioniListBySistemaErogante4]
  @utente VARCHAR (64)
, @idUnitaOperativa UNIQUEIDENTIFIER
, @idSistemaRichiedente UNIQUEIDENTIFIER
, @idSistemaErogante UNIQUEIDENTIFIER
, @codiceRegime VARCHAR (16)
, @codicePriorita VARCHAR (16)
, @idStato TINYINT=1
, @valore VARCHAR (256)
AS
BEGIN
	SET NOCOUNT ON;

	-- Imposta il primo giorno della settimana su un numero compreso tra 1 e 7.
	SET DATEFIRST 1

	--Se filtro scarso abbasso il TOP
	DECLARE @MaxRecord INT = 2000
	IF @valore IS NULL OR LEN(@valore) < 2
		SET @MaxRecord = 500

	-- Prestazioni richiedibili
	DECLARE @RIC TABLE (Id uniqueidentifier, IdSistemaErogante uniqueidentifier) 
	INSERT INTO @RIC 
		SELECT Id, IdSistemaErogante
		FROM dbo.GetPrestazioniRichiedibili2(@utente, @idUnitaOperativa, @idSistemaRichiedente
												, GETDATE(), @codiceRegime, @codicePriorita
												, @idStato, @idSistemaErogante, @valore
												, NULL, 1, 1)
	--Cerco tra prestazioni del paziente
	SELECT DISTINCT TOP(@MaxRecord) P.*
	FROM dbo.CorePrestazioniList P

		--Prestazioni richiedibili 
		INNER JOIN @RIC PR ON PR.ID = P.ID

	WHERE PR.IdSistemaErogante = @idSistemaErogante
	ORDER BY Codice

	-- Modify date: 2018-02-07 SANDRO: Problema saltuario di time-out invece che quanche sec di exec
	OPTION (RECOMPILE)
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniListBySistemaErogante4] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniListBySistemaErogante4] TO [DataAccessWs]
    AS [dbo];

