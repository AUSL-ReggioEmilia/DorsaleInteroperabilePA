








-- =============================================
-- Author:      Ettore
-- Create date: 2017-10-13
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Description: Derivata dalla [dbo].[GetRefertoOscuramentiPuntuali] e dbo.GetRefertoOscuramenti()
--				Restituisce la lista degli Oscuramenti si un referto
--				In base ai paramentri discrimina fra Oscuramenti Puntuali/Massivi e oscuramenti da applicare al DWH o a SOLE
--				Il parametro @IdOscuramento deve essere valorizzato SOLO nel BackEnd per la rinotifica di referti a seguito di modifica di un oscuramento PUNTUALE
-- =============================================
CREATE FUNCTION [dbo].[OttieniRefertoOscuramenti]
(
 @IdOscuramento UNIQUEIDENTIFIER, --questo può essere null
 @TipoOscuramento VARCHAR(16),
 @Scope VARCHAR(16),
 @IdEsternoReferto varchar(64),		--PUNTUALI
 @IdReferto uniqueidentifier,		--MASSIVI
 @DataPartizione smalldatetime,		--MASSIVI
 @AziendaErogante varchar(16),		--PUNTUALI/MASSIVI
 @SistemaErogante varchar(16),		--PUNTUALI/MASSIVI
 @NumeroNosologico varchar(64),		--PUNTUALI/MASSIVI
 @NumeroPrenotazione varchar(32),	--PUNTUALI
 @NumeroReferto varchar(16),		--PUNTUALI
 @IdOrderEntry varchar(64),			--PUNTUALI
 @StrutturaEroganteCodice varchar(16),	--MASSIVI
 @RepartoRichiedenteCodice varchar(16),	--MASSIVI
 @RepartoErogante varchar(64),	--MASSIVI
 @Confidenziale AS BIT			--MASSIVI
)  
RETURNS TABLE
AS
	RETURN
	
	SELECT 
		Oscuramenti.CodiceOscuramento
	  , OscuramentoRuoli.IdRuolo
		
	FROM dbo.Oscuramenti
		LEFT JOIN dbo.OscuramentoRuoli
			ON Oscuramenti.Id = OscuramentoRuoli.IdOscuramento
	WHERE 	
	(
		(@IdOscuramento IS NULL AND Stato IN ('Completato'))
		OR
		(Oscuramenti.Id = @IdOscuramento)
	)
	AND 
	(
		--Oscuramenti MASSIVI per DWH
		(
			(@TipoOscuramento = 'Massivi' AND @Scope = 'DWH' AND ApplicaDWH = 1)
			AND
			(
				( --0) Tipo di sistema
					TipoOscuramento = 0
					AND
					@Confidenziale = 1 	
				)	

				OR	
				( --2) reparto richiedente (+ sistema) (+ azienda)
					TipoOscuramento = 2
					AND
					RepartoRichiedenteCodice = @RepartoRichiedenteCodice
					AND 
					(SistemaErogante IS NULL OR SistemaErogante = @SistemaErogante)
					AND 
					(AziendaErogante IS NULL OR AziendaErogante = @AziendaErogante)
				)						
	
				OR
				( --6) azienda + sistema + reparto (+ struttura) eroganti
					TipoOscuramento = 6
					AND
					AziendaErogante = @AziendaErogante 
					AND
					SistemaErogante = @SistemaErogante 
					AND
					RepartoErogante = @RepartoErogante
					AND
					(StrutturaEroganteCodice IS NULL OR StrutturaEroganteCodice = @StrutturaEroganteCodice)		
				)
			
				OR 
				(-- 7) Reparto di Ricovero
					TipoOscuramento = 7
					AND
					--Solo se la riga della tabella Oscuramenti è il filtro per Reparto di Ricovero
					-- Modify date: 2017-04-07 Ettore: Adeguamento per gestire sistemi eroganti di ricoveri diversi da ADT: filtro usando il valore sulla tabella parametro @SistemaErogante
					--SistemaErogante = 'ADT' --filtrava la tabella degli oscuramenti per l'unico sistema che erogava ricoveri
					--Il filtro SistemaErogante = "sistema che eroga ricoveri" non serve perchè è sempre verificato!!!
					--SistemaErogante IN (SELECT SistemaErogante FROM SistemiEroganti WHERE TipoRicoveri = 1)
					--AND 
					(AziendaErogante IS NULL OR AziendaErogante = @AziendaErogante)
					AND	EXISTS
					(	SELECT 1
						FROM   
							store.EventiBase AS E
						WHERE  
							E.StatoCodice = 0
							AND E.TipoEventoCodice IN ('A','T','D','IL','ML')
							--verifico se il nosologico sul referto contiene reparti di ricovero oscurati
							AND E.NumeroNosologico = @NumeroNosologico	
							--l'azienda erogante delle evento è uguale all'azienda nel record di oscuramento oppure l'azienda nell'oscuramento non è stata impostata
							AND (E.AziendaErogante = AziendaErogante OR AziendaErogante IS NULL) 
							--il reparto di ricovero dell'evento è uguale a quello impostato nell'oscuramento
							AND E.RepartoCodice = RepartoRichiedenteCodice
							-- Modify date: 2017-04-07 Ettore: Adeguamento per gestire sistemi eroganti di ricoveri diversi da ADT
							-- Il sistema erogante dell'evento è quello impostato sull'oscuramento
							AND E.SistemaErogante = SistemaErogante
					)
				)
	
				OR 
				(-- 8) Parola chiave
					TipoOscuramento = 8
					AND	EXISTS 
					(	SELECT 1 
						FROM 
							store.PrestazioniBase WITH(NOLOCK) 
						WHERE 
							IdRefertiBase = @IdReferto
							AND DataPartizione = @DataPartizione
							AND (PrestazioneDescrizione LIKE '%' + Parola + '%'
									OR SezioneDescrizione LIKE '%' + Parola + '%')
					)	
			
				)
			)
		) --FINE Oscuramenti MASSIVI per DWH
		OR
		--Oscuramenti MASSIVI per SOLE
		(
			(@TipoOscuramento = 'Massivi' AND @Scope = 'SOLE' AND ApplicaSole = 1)
			AND
			(
				--( --0) Tipo di sistema, su SOLE la verifica ha un flag specifico
				--	TipoOscuramento = 0
				--	AND
				--	@Confidenziale = 1 	
				--)	
	
				--OR	
				( --2) reparto richiedente (+ sistema) (+ azienda)
					TipoOscuramento = 2
					AND
					RepartoRichiedenteCodice = @RepartoRichiedenteCodice
					AND 
					(SistemaErogante IS NULL OR SistemaErogante = @SistemaErogante)
					AND 
					(AziendaErogante IS NULL OR AziendaErogante = @AziendaErogante)
				)						
	
				OR
				( --6) azienda + sistema + reparto (+ struttura) eroganti
					TipoOscuramento = 6
					AND
					AziendaErogante = @AziendaErogante 
					AND
					SistemaErogante = @SistemaErogante 
					AND
					RepartoErogante = @RepartoErogante
					AND
					(StrutturaEroganteCodice IS NULL 
						OR StrutturaEroganteCodice = @StrutturaEroganteCodice
					)		
				)
			
				OR 
				(-- 7) Reparto di Ricovero
					TipoOscuramento = 7
					AND
					--Solo se la riga della tabella Oscuramenti è il filtro per Reparto di Ricovero
					-- Modify date: 2017-04-07 Ettore: Adeguamento per gestire sistemi eroganti di ricoveri diversi da ADT: filtro usando il valore sulla tabella parametro @SistemaErogante
					--SistemaErogante = 'ADT' --filtrava la tabella degli oscuramenti per l'unico sistema che erogava ricoveri
					--Il filtro SistemaErogante = "sistema che eroga ricoveri" non serve perchè è sempre verificato!!!
					--SistemaErogante IN (SELECT SistemaErogante FROM SistemiEroganti WHERE TipoRicoveri = 1)
					--AND 
					(AziendaErogante IS NULL OR AziendaErogante = @AziendaErogante)
					AND	EXISTS
					(	SELECT 1
						FROM   
							store.EventiBase AS E
						WHERE  
							E.StatoCodice = 0
							AND E.TipoEventoCodice IN ('A','T','D','IL','ML')
							--verifico se il nosologico sul referto contiene reparti di ricovero oscurati
							AND E.NumeroNosologico = @NumeroNosologico	
							--l'azienda erogante delle evento è uguale all'azienda nel record di oscuramento oppure l'azienda nell'oscuramento non è stata impostata
							AND (E.AziendaErogante = AziendaErogante OR AziendaErogante IS NULL) 
							--il reparto di ricovero dell'evento è uguale a quello impostato nell'oscuramento
							AND E.RepartoCodice = RepartoRichiedenteCodice
							-- Modify date: 2017-04-07 Ettore: Adeguamento per gestire sistemi eroganti di ricoveri diversi da ADT
							-- Il sistema erogante dell'evento è quello impostato sull'oscuramento
							AND E.SistemaErogante = SistemaErogante
					)
				)
	
				OR 
				(-- 8) Parola chiave
					TipoOscuramento = 8
					AND	EXISTS 
					(	SELECT 1 
						FROM 
							store.PrestazioniBase WITH(NOLOCK) 
						WHERE 
							IdRefertiBase = @IdReferto
							AND DataPartizione = @DataPartizione
							AND (PrestazioneDescrizione LIKE '%' + Parola + '%'
									OR SezioneDescrizione LIKE '%' + Parola + '%')
					)	
				)
			)
		)--FINE Oscuramenti MASSIVI per SOLE
		OR
		(--Oscuramenti PUNTUALI Per DWH
			(@TipoOscuramento = 'Puntuali' AND @Scope = 'DWH' AND ApplicaDWH = 1)
			AND
			(
				( --1) azienda erogante + nosologico
						TipoOscuramento = 1
						AND
						AziendaErogante = @AziendaErogante 
						AND
						NumeroNosologico = @NumeroNosologico 
				)	
				OR
				( --3) Numero Referto (+ sistema) (+ azienda)
					TipoOscuramento = 3
					AND
					NumeroReferto = @NumeroReferto
					AND
					(SistemaErogante IS NULL OR SistemaErogante = @SistemaErogante)
					AND
					(AziendaErogante IS NULL OR AziendaErogante = @AziendaErogante) 		 	
				)
				OR
				( --4) Numero Prenotazione (+ sistema) (+ azienda)
					TipoOscuramento = 4
					AND
					NumeroPrenotazione = @NumeroPrenotazione
					AND
					(SistemaErogante IS NULL OR SistemaErogante = @SistemaErogante)
					AND
					(AziendaErogante IS NULL OR AziendaErogante = @AziendaErogante) 		 	
				)
				OR
				( --5) id order entry (+ sistema) (+ azienda)
					TipoOscuramento = 5
					AND
					IdOrderEntry = @IdOrderEntry
					AND
					(SistemaErogante IS NULL OR SistemaErogante = @SistemaErogante)
					AND
					(AziendaErogante IS NULL OR AziendaErogante = @AziendaErogante) 		 	
				)
				OR
				( --9) 
					TipoOscuramento = 9
					AND
					IdEsternoReferto = @IdEsternoReferto
				)
			)
		) --FINE Oscuramenti PUNTUALI Per DWH
		OR
		(-- OSCURAMENTI PUNTUALI per SOLE
			(@TipoOscuramento = 'Puntuali' AND @Scope = 'SOLE' AND ApplicaSole = 1)
			--Oscuramenti PUNTUALI Per DWH
			AND
			(
				( --1) azienda erogante + nosologico
						TipoOscuramento = 1
						AND
						AziendaErogante = @AziendaErogante 
						AND
						NumeroNosologico = @NumeroNosologico 
				)	
				OR
				( --3) Numero Referto (+ sistema) (+ azienda)
					TipoOscuramento = 3
					AND
					NumeroReferto = @NumeroReferto
					AND
					(SistemaErogante IS NULL OR SistemaErogante = @SistemaErogante)
					AND
					(AziendaErogante IS NULL OR AziendaErogante = @AziendaErogante) 		 	
				)
				OR
				( --4) Numero Prenotazione (+ sistema) (+ azienda)
					TipoOscuramento = 4
					AND
					NumeroPrenotazione = @NumeroPrenotazione
					AND
					(SistemaErogante IS NULL OR SistemaErogante = @SistemaErogante)
					AND
					(AziendaErogante IS NULL OR AziendaErogante = @AziendaErogante) 		 	
				)
				OR
				( --5) id order entry (+ sistema) (+ azienda)
					TipoOscuramento = 5
					AND
					IdOrderEntry = @IdOrderEntry
					AND
					(SistemaErogante IS NULL OR SistemaErogante = @SistemaErogante)
					AND
					(AziendaErogante IS NULL OR AziendaErogante = @AziendaErogante) 		 	
				)
				OR
				( --9) 
					TipoOscuramento = 9
					AND
					IdEsternoReferto = @IdEsternoReferto
				)
			)
		) -- FINE OSCURAMENTI PUNTUALI per SOLE
	)