
-- =============================================
-- Author:      ETTORE
-- Create date: 2017-12-20
-- Modify date: 2019-01-21 - SANDRO - Usa nuovo SP SOLE ([sole].[CodaRefertiAggiungi])
-- Description: Inserisce una riga in dbo.CodaRefertiSole
--				Solo i referti "Completati" devono essere inviati a SOLE (R.StatoRichiestaCodice = 1)
-- =============================================
CREATE PROCEDURE [frontend].[CodaRefertiSoleInserisce]
(
	@IdOscuramento UNIQUEIDENTIFIER
)
AS
BEGIN

	SET NOCOUNT OFF
	--
	-- DICHIARO LA TABELLA TEMPORANEA
	--
	DECLARE @TableReferti AS TABLE(IdReferto UNIQUEIDENTIFIER, DataModifica DATETIME
					,AziendaErogante VARCHAR(16), SistemaErogante VARCHAR(16)
					,StatoRichiestaCodice TINYINT, Messaggio XML)
	--
	-- RIEMPO LA TABELLA TEMPORANEA ESCLUDENTO IL TIPO DI EVENTO FITTIZIO LA.
	--2019-01-16 Agiunto DataModifica, rimosso DataModificaEsterno
	--
    INSERT INTO @TableReferti
		(
		IdReferto,
		DataModifica,
		AziendaErogante,
		SistemaErogante,
		StatoRichiestaCodice,
		Messaggio
		)
	SELECT R.ID,
		R.DataModifica,
		R.AziendaErogante,
		R.SistemaErogante,
		R.StatoRichiestaCodice,
		[sole].[OttieneRefertoXml](R.ID) AS Messaggio
		FROM store.RefertiBase AS R
			CROSS APPLY [dbo].[OttieniRefertoOscuramenti](@IdOscuramento,'puntuali','SOLE',r.IdEsterno,r.ID,r.DataPartizione,
						r.AziendaErogante,r.SistemaErogante,r.NumeroNosologico,r.NumeroPrenotazione,r.NumeroReferto,r.IdOrderEntry,null,
						r.RepartoRichiedenteCodice,r.RepartoErogante,NULL) AS RO
		--Solo i referti "Completati" devono essere inviati a SOLE 
		WHERE R.StatoRichiestaCodice = 1

	IF EXISTS (SELECT * FROM @TableReferti)
	BEGIN
		---------------------------------------------------------------------------------------
		-- Eseguo l'inserimento nella tabella di output SOLE
		---------------------------------------------------------------------------------------
		--
		-- Inserisco gli altri eventi nell'ordine di ingresso
		--
		DECLARE @cur_IdReferto uniqueidentifier
		DECLARE @Cur_DataModifica DATETIME
		DECLARE @Cur_AziendaErogante varchar(16)
		DECLARE @Cur_SistemaErogante VARCHAR(16)
		DECLARE @cur_StatoRichiestaCodice TINYINT
		DECLARE @cur_Messaggio XML

		DECLARE cur_Referti CURSOR STATIC READ_ONLY FOR	
		SELECT IdReferto
			, DataModifica
			, AziendaErogante
			, SistemaErogante
			, StatoRichiestaCodice
			, Messaggio
		FROM @TableReferti 
		ORDER BY DataModifica ASC

		OPEN cur_Referti
		FETCH NEXT FROM cur_Referti INTO @cur_IdReferto, @Cur_DataModifica, @Cur_AziendaErogante, @Cur_SistemaErogante
										, @cur_StatoRichiestaCodice, @cur_Messaggio
		WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
			BEGIN

				EXEC [sole].[CodaRefertiAggiungi] @cur_IdReferto, 2, 'Oscuramenti', @cur_AziendaErogante
											, @cur_SistemaErogante, @cur_StatoRichiestaCodice
											, @cur_DataModifica, @cur_Messaggio

			END
			-- Prossima riga
			FETCH NEXT FROM cur_Referti INTO @cur_IdReferto, @Cur_DataModifica, @Cur_AziendaErogante, @Cur_SistemaErogante
											, @cur_StatoRichiestaCodice, @cur_Messaggio
		END
		-- Fine
		CLOSE cur_Referti
		DEALLOCATE cur_Referti

	END
END