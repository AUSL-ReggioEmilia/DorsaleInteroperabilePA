
-- =============================================
-- Author:		Simone Bitti
-- Create date: 2017-02-23
-- Description:	Seleziona la ennuple dei dati accessori in base ai prametri.
-- =============================================

CREATE PROCEDURE [dbo].[UiSimulazioneEnnupleDatiAccessoriInteressateList]
	  @nomeUtente varchar(64)
	, @giorno as datetime2(0) 
	, @idUnitaOperativa uniqueidentifier
	, @idSistemaRichiedente uniqueidentifier
	, @codiceRegime varchar(16)
	, @codicePriorita varchar(16)
	, @idStato as tinyint = NULL
AS
BEGIN
	SET NOCOUNT ON;

	-- Imposta il primo giorno della settimana su un numero compreso tra 1 e 7.
	SET DATEFIRST 1
		
	BEGIN TRY
	
	DECLARE @weekday int = DATEPART(dw,@giorno)
	DECLARE @time varchar(8) = CONVERT(varchar(8),@giorno,108)
	
	    -- Tutte le ennuple coinvolte
		--	DISTINCT
		SELECT TOP 2000
			E.Descrizione + CASE WHEN E.[Not] = 1 THEN ' (Not)'  ELSE '' END as Ennupla, 
			ISNULL(DatiAccessori.Etichetta, 'Tutti') as Gruppo		
		FROM EnnupleDatiAccessori E 
			LEFT JOIN DatiAccessori
				ON E.CodiceDatoAccessorio = DatiAccessori.Codice
		WHERE
				-- Per tutti o per un gruppo specifico
				( E.IDGruppoUtenti IS NULL
					OR e.IDGruppoUtenti IN (SELECT ID FROM [dbo].[GetGruppiOePerUtente](@nomeUtente))
				)
					
			-- orario
			AND ((OrarioInizio IS NULL) OR (@time >= OrarioInizio AND @time <= OrarioFine))									
				
				-- giorno della settimana
			AND ((@weekday = (CASE WHEN Lunedi = 1 THEN 1 END)) OR
				 (@weekday = (CASE WHEN Martedi = 1 THEN 2 END)) OR
				 (@weekday = (CASE WHEN Mercoledi = 1 THEN 3 END)) OR
				 (@weekday = (CASE WHEN Giovedi = 1 THEN 4 END)) OR
				 (@weekday = (CASE WHEN Venerdi = 1 THEN 5 END)) OR
				 (@weekday = (CASE WHEN Sabato = 1 THEN 6 END)) OR
				 (@weekday = (CASE WHEN Domenica = 1 THEN 7 END)))
			
				-- unità operativa
			AND ((E.IDUnitaOperativa IS NULL) OR (E.IDUnitaOperativa = @idUnitaOperativa))
			
				-- sistema richiedente
			AND ((E.IDSistemaRichiedente IS NULL) OR (E.IDSistemaRichiedente = @idSistemaRichiedente))
			
				-- codice regime
			AND ((E.CodiceRegime IS NULL) OR (E.CodiceRegime = @codiceRegime))
			
				-- sistema priorità
			AND ((E.CodicePriorita IS NULL) OR (E.CodicePriorita = @codicePriorita))
			
				-- stato
			AND	(@idStato is null or E.IDStato = @idStato)
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiSimulazioneEnnupleDatiAccessoriInteressateList] TO [DataAccessUi]
    AS [dbo];

