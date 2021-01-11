
CREATE FUNCTION [dbo].[GetUiEnnuple1]
(
	  @Utente varchar(64)
	, @giorno as datetime2(0) 
	, @idUnitaOperativa uniqueidentifier
	, @idSistemaRichiedente uniqueidentifier
	, @codiceRegime varchar(16)
	, @codicePriorita varchar(16)
	, @idStato as tinyint = NULL
)
RETURNS @Result TABLE (IdGruppoPrestazioni uniqueidentifier, [Not] bit NOT NULL) 
AS
BEGIN

	DECLARE @weekday int = DATEPART(dw,@giorno)
	DECLARE @time varchar(8) = CONVERT(varchar(8),@giorno,108)

	INSERT INTO @Result
		SELECT e.IDGruppoPrestazioni, e.[Not]
		FROM Ennuple e
		WHERE
				-- Per tutti o per un gruppo specifico
				( e.IDGruppoUtenti IS NULL
					OR e.IDGruppoUtenti IN (SELECT ID FROM [dbo].[GetGruppiOePerUtente](@Utente))
				)
					
				-- orario
			AND ((e.OrarioInizio IS NULL) OR (@time >= e.OrarioInizio AND @time <= OrarioFine))									
				
				-- giorno della settimana
			AND ((@weekday = (CASE WHEN e.Lunedi = 1 THEN 1 END)) OR
				 (@weekday = (CASE WHEN e.Martedi = 1 THEN 2 END)) OR
				 (@weekday = (CASE WHEN e.Mercoledi = 1 THEN 3 END)) OR
				 (@weekday = (CASE WHEN e.Giovedi = 1 THEN 4 END)) OR
				 (@weekday = (CASE WHEN e.Venerdi = 1 THEN 5 END)) OR
				 (@weekday = (CASE WHEN e.Sabato = 1 THEN 6 END)) OR
				 (@weekday = (CASE WHEN e.Domenica = 1 THEN 7 END)))
			
				-- unità operativa
			AND ((e.IDUnitaOperativa IS NULL) OR (e.IDUnitaOperativa = @idUnitaOperativa))
			
				-- sistema richiedente
			AND ((e.IDSistemaRichiedente IS NULL) OR (e.IDSistemaRichiedente = @idSistemaRichiedente))
			
				-- codice regime
			AND ((e.CodiceRegime IS NULL) OR (e.CodiceRegime = @codiceRegime))
			
				-- sistema priorità
			AND ((e.CodicePriorita IS NULL) OR (e.CodicePriorita = @codicePriorita))
			
				-- stato
			AND (@idStato IS NULL OR e.IDStato = @idStato)
	RETURN 
END
