

-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2014-10-23
-- Modify date: 2014-11-04 SANDRO: Usa la nuova Func GetPrestazioniRichiedibili() per valutare l'accesso
-- Modify date: 2018-02-07 SANDRO: Problema saltuario di time-out invece che quanche sec di exec
--									Rimosso WITH RECOMPILE e aggiunto OPTION (RECOMPILE)
-- Modify date: 2018-02-19 SANDRO: Nuova Func GetPrestazioniRichiedibili2 (filtra per IdGruppoPrestazioni)
--
-- Description:	Ritorna un elenco di prestazioni (con accesso) di un gruppo
-- =============================================
CREATE PROCEDURE [dbo].[CorePrestazioniListByIdGruppo]
( @utente varchar(64)
, @idUnitaOperativa uniqueidentifier
, @idSistemaRichiedente uniqueidentifier
, @idSistemaErogante uniqueidentifier
, @codiceRegime varchar(16)
, @codicePriorita varchar(16)
, @idStato tinyint = 1
, @IdGruppoPrestazione uniqueidentifier
, @valore varchar(256) = NULL
)
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
	DECLARE @RIC TABLE (Id uniqueidentifier)
	
	IF NOT @IdGruppoPrestazione IS NULL
		INSERT INTO @RIC 
		SELECT Id FROM dbo.GetPrestazioniRichiedibili2(@utente, @idUnitaOperativa, @idSistemaRichiedente
												, GETDATE(), @codiceRegime, @codicePriorita
												, @idStato, @idSistemaErogante, @valore
												, @IdGruppoPrestazione, 1, 1)
	--Cerco tra prestazioni del gruppo
	SELECT DISTINCT TOP(@MaxRecord) P.*
	FROM dbo.CorePrestazioniList P

		-- Prestazioni richiedibili
		INNER JOIN @RIC PR ON PR.ID = P.ID

	WHERE (@idSistemaErogante IS NULL OR P.IDSistemaErogante = @idSistemaErogante)
		AND	(@valore IS NULL OR (P.Codice Like '%' + @valore + '%' OR P.Descrizione Like '%' + @valore + '%'))


	ORDER BY P.Codice
	-- Modify date: 2018-02-07 SANDRO: Problema saltuario di time-out invece che quanche sec di exec
	OPTION (RECOMPILE)

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniListByIdGruppo] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniListByIdGruppo] TO [DataAccessWs]
    AS [dbo];

