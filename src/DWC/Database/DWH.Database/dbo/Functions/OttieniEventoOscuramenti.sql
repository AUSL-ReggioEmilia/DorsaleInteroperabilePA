









-- =============================================
-- Author:      ETTORE
-- Create date: 2017-10-13
-- Description: Derivata dalla [dbo].[GetEventoOscuramentiPuntuali] e dbo.GetEventoOscuramenti()
--				Restituisce la lista degli Oscuramenti di un evento
--				In base ai paramentri discrimina fra Oscuramenti Puntuali/Massivi e oscuramenti da applicare al DWH o a SOLE
--				Il parametro @IdOscuramento deve essere valorizzato SOLO nel BackEnd per la rinotifica di eventi a seguito di modifica di un oscuramento PUNTUALE
-- Modify date: 2017-11-03 Ettore: Aggiunto il nuovo oscuramento massivo per parola (Tipo=10) dedicato a Eventi e Ricoveri
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- =============================================
CREATE FUNCTION [dbo].[OttieniEventoOscuramenti]
(
	@IdOscuramento UNIQUEIDENTIFIER, --questo può essere null
	@TipoOscuramento VARCHAR(16),
	@Scope VARCHAR(16),
	@AziendaErogante varchar(16), --massivo
	@NumeroNosologico varchar(64) --massivo
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
		(
			--Massivo DWH
			(@TipoOscuramento = 'Massivi' AND @Scope = 'DWH' AND ApplicaDWH = 1)
			AND
			(
				(-- 1) azienda erogante + nosologico
					TipoOscuramento = 1
					AND
					AziendaErogante = @AziendaErogante
					AND
					NumeroNosologico = @NumeroNosologico 
				)	
				OR 
				(-- 7) Reparto di Ricovero
					TipoOscuramento = 7
					AND
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
							AND E.SistemaErogante = SistemaErogante
					)
				)
				OR
				(-- 10) Parola chiave
					TipoOscuramento = 10 --solo per eventi e ricoveri
					AND	EXISTS 
					(	SELECT 1 
						FROM 
							store.EventiBase WITH(NOLOCK) 
						WHERE 
							AziendaErogante = @AziendaErogante
							AND NumeroNosologico  = @NumeroNosologico
							--AND DataPartizione = @DataPartizione
							AND (Diagnosi LIKE '%' + Parola + '%')
					)	
				)
			)--Fine Massivo DWH
		)
		OR
		(	--Oscuramenti massivi SOLE
			(@TipoOscuramento = 'Massivi' AND @Scope = 'SOLE' AND ApplicaSOLE = 1)
			AND
			(
				(-- 1) azienda erogante + nosologico
					TipoOscuramento = 1
					AND
					AziendaErogante = @AziendaErogante
					AND
					NumeroNosologico = @NumeroNosologico 
				)	
				OR 
				(-- 7) Reparto di Ricovero
					TipoOscuramento = 7
					AND
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
							AND E.SistemaErogante = SistemaErogante
					)
				)
				OR
				(-- 10) Parola chiave
					TipoOscuramento = 10 --solo per eventi e ricoveri
					AND	EXISTS 
					(	SELECT 1 
						FROM 
							store.EventiBase WITH(NOLOCK) 
						WHERE 
							AziendaErogante = @AziendaErogante
							AND NumeroNosologico  = @NumeroNosologico
							--AND DataPartizione = @DataPartizione
							AND (Diagnosi LIKE '%' + Parola + '%')
					)	
				)
			)
		)--Fine Oscuramenti massivi SOLE
		OR
		( --Puntuali DWH
			(@TipoOscuramento = 'Puntuali' AND @Scope = 'DWH' AND ApplicaDWH = 1)
			AND
			(
				(-- 1) azienda erogante + nosologico
					TipoOscuramento = 1
					AND
					AziendaErogante = @AziendaErogante
					AND
					NumeroNosologico = @NumeroNosologico 
				)	
			)
		) --FINE Puntuali DWH
		OR
		( --Puntuali SOLE
			(@TipoOscuramento = 'Puntuali' AND @Scope = 'SOLE' AND ApplicaSOLE = 1)
			AND
			(
				(-- 1) azienda erogante + nosologico
					TipoOscuramento = 1
					AND
					AziendaErogante = @AziendaErogante
					AND
					NumeroNosologico = @NumeroNosologico 
				)	
			)
		) --FINE Puntuali SOLE
	)