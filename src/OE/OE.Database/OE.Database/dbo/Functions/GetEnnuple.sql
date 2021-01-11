CREATE FUNCTION [dbo].[GetEnnuple]
(@Utente VARCHAR (64), @idUnitaOperativa UNIQUEIDENTIFIER, @idSistemaRichiedente UNIQUEIDENTIFIER, @idSistemaErogante UNIQUEIDENTIFIER, @codiceRegime VARCHAR (16), @codicePriorita VARCHAR (16), @idStato TINYINT=1)
RETURNS 
    @Result TABLE (
        [IdGruppoPrestazioni] UNIQUEIDENTIFIER NULL,
        [Not]                 BIT              NOT NULL)
AS
BEGIN
	-- @idSistemaErogante Non è usato

	DECLARE @weekday int = DATEPART(dw,GETDATE())
	DECLARE @time varchar(8) = CONVERT(varchar(8),GETDATE(),108)

	INSERT INTO @Result
		SELECT e.IDGruppoPrestazioni, e.[Not]
		FROM Ennuple e
		WHERE
			-- Per tutti o per un gruppo specifico
			( e.IDGruppoUtenti IS NULL
				OR e.IDGruppoUtenti IN (SELECT ID FROM [dbo].[GetGruppiOePerUtente](@Utente))
			)

			--Orario e giorni			
			AND (e.OrarioInizio IS NULL OR (@time >= e.OrarioInizio AND @time <= OrarioFine))																	
			AND ((@weekday = (CASE WHEN e.Lunedi = 1 THEN 1 END)) OR
				   (@weekday = (CASE WHEN e.Martedi = 1 THEN 2 END)) OR
				   (@weekday = (CASE WHEN e.Mercoledi = 1 THEN 3 END)) OR
				   (@weekday = (CASE WHEN e.Giovedi = 1 THEN 4 END)) OR
				   (@weekday = (CASE WHEN e.Venerdi = 1 THEN 5 END)) OR
				   (@weekday = (CASE WHEN e.Sabato = 1 THEN 6 END)) OR
				   (@weekday = (CASE WHEN e.Domenica = 1 THEN 7 END)))

			-- Per tutti o senza filtro o filtrato
			AND (e.IDUnitaOperativa IS NULL OR e.IDUnitaOperativa = @idUnitaOperativa OR @idUnitaOperativa IS NULL)
			AND (e.IDSistemaRichiedente IS NULL OR e.IDSistemaRichiedente = @idSistemaRichiedente OR @idSistemaRichiedente IS NULL)
			AND (e.CodiceRegime IS NULL OR e.CodiceRegime = @codiceRegime OR @codiceRegime IS NULL)
			AND (e.CodicePriorita IS NULL OR e.CodicePriorita = @codicePriorita OR @codicePriorita IS NULL)

			-- Stato dell aennupla
			AND e.IDStato = @idStato

		ORDER BY DATEDIFF(second, e.OrarioInizio , e.OrarioFine), e.OrarioInizio, e.OrarioFine
	
	RETURN 
END


