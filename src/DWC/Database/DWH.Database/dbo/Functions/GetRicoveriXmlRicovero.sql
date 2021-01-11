

-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste delllo schema "store" al posto delle viste dello schema "dbo"
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[GetRicoveriXmlRicovero] (@AziendaErogante VARCHAR(16), @NumeroNosologico VARCHAR(64))  
RETURNS xml AS  
BEGIN 

DECLARE @Ret xml

	IF (NOT @AziendaErogante IS NULL) AND (NOT @NumeroNosologico IS NULL)
		--
		-- Solo per i dati
		--
		SET @Ret = (
			SELECT 
				--Dati evento
				Evento.Id,  
				Evento.AziendaErogante, 
				--Evento.SistemaErogante, sempre ADT
				Evento.RepartoErogante, 
				Evento.DataEvento, 
				Evento.StatoCodice,
				Evento.TipoEventoCodice,
				Evento.TipoEventoDescr,
				Evento.NumeroNosologico, 
				Evento.TipoEpisodio,
				Evento.RepartoCodice,
				Evento.RepartoDescr,
				Evento.Diagnosi,
				--Dati attributi dell'evento
				Attributo.Nome, 
				Attributo.Valore
			FROM 
				store.EventiBase AS Evento 
				INNER JOIN store.EventiAttributi AS Attributo
						ON Evento.Id = Attributo.IdEventiBase
			WHERE 
				Evento.AziendaErogante = @AziendaERogante
				AND Evento.SistemaErogante = 'ADT'
				AND Evento.NumeroNosologico  = @NumeroNosologico
			FOR XML AUTO, ELEMENTS
					)
	ELSE
		--
		-- Solo per lo schema
		--
		SET @Ret = (
			SELECT 
				--Dati evento
				Evento.Id,  
				Evento.AziendaErogante, 
				--Evento.SistemaErogante, sempre ADT
				Evento.RepartoErogante, 
				Evento.DataEvento, 
				Evento.StatoCodice,
				Evento.TipoEventoCodice,
				Evento.TipoEventoDescr,
				Evento.NumeroNosologico, 
				Evento.TipoEpisodio,
				Evento.RepartoCodice,
				Evento.RepartoDescr,
				Evento.Diagnosi,
				--Dati attributi dell'evento
				Attributo.Nome, 
				Attributo.Valore
			FROM 
				store.EventiBase AS Evento 
				INNER JOIN store.EventiAttributi AS Attributo
						ON Evento.Id = Attributo.IdEventiBase
			WHERE 1=2
			FOR XML AUTO, ELEMENTS, XMLDATA
					)
	RETURN @Ret
END

