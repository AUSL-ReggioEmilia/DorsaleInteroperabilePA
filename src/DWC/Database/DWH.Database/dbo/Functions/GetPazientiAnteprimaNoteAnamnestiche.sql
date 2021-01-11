


-- =============================================
-- Author:		ETTORE
-- Create date: 2017-11-22
-- Description:	Restituisce i dati di anteprima delle note anamnestiche del paziente
--				Utilizzata nella SP di manteinance dei deati di anterpima per le note anamnestiche
-- =============================================
CREATE FUNCTION [dbo].[GetPazientiAnteprimaNoteAnamnestiche]
(
	@IdPaziente uniqueidentifier
)
RETURNS @RetTable TABLE 
	(NumeroNoteAnamnestiche INT
	, UltimaNotaAnamnesticaData DATETIME
	, UltimaNotaAnamnesticaSistemaEroganteDescr VARCHAR(128)
	)	
AS
BEGIN
	DECLARE @NumeroNoteAnamnestiche INT = 0
	DECLARE @UltimaNotaAnamnesticaData DATETIME
	DECLARE @UltimaNotaAnamnesticaSistemaEroganteDescr VARCHAR(128)

	DECLARE @TmpNoteAnamnestiche AS TABLE (NumeroNoteAnamnestiche INT, AziendaErogante VARCHAR(16), SistemaErogante VARCHAR(16), DataNota DATETIME)
	--
	-- Lista dei fusi + l'attivo
	--
	DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
	INSERT INTO @TablePazienti(Id)
		SELECT Id
		FROM dbo.GetPazientiDaCercareByIdSac(@IdPaziente)
	--
	-- Cerco i dati delle note anamnestiche che mi servono da visualizzare nell'anteprima
	--
	INSERT INTO @TmpNoteAnamnestiche (NumeroNoteAnamnestiche, AziendaErogante, SistemaErogante, DataNota )
	SELECT COUNT(*), AziendaErogante, SistemaErogante, DataNota 
	FROM ws3.NoteAnamnestiche AS N --WITH(NOLOCK) 
		INNER JOIN @TablePazienti Pazienti 
			ON N.IdPaziente = Pazienti.Id
	GROUP BY AziendaErogante, SistemaErogante, DataNota
	--
	-- Calcolo il numero delle note anamnestiche
	--
	SELECT @NumeroNoteAnamnestiche = ISNULL(SUM(NumeroNoteAnamnestiche), 0) FROM @TmpNoteAnamnestiche
	--Determino i dati associati all'ultima nota anamnestica
	IF @NumeroNoteAnamnestiche > 0 
	BEGIN
		SELECT TOP 1
			@UltimaNotaAnamnesticaData = MAX(TAB.DataNota)
			, @UltimaNotaAnamnesticaSistemaEroganteDescr = 
						(SELECT TOP 1 Descrizione FROM SistemiEroganti WHERE AziendaErogante = TAB.AziendaErogante AND SistemaErogante = TAB.SistemaErogante) --TAB.SistemaErogante
		FROM 
			@TmpNoteAnamnestiche AS TAB
		GROUP BY TAB.AziendaErogante, TAB.SistemaErogante
		ORDER BY MAX(TAB.DataNota) DESC 
	END 
	--
	-- Restituisco
	--
	INSERT INTO @RetTable(NumeroNoteAnamnestiche, UltimaNotaAnamnesticaData, UltimaNotaAnamnesticaSistemaEroganteDescr)
	VALUES (@NumeroNoteAnamnestiche, @UltimaNotaAnamnesticaData, @UltimaNotaAnamnesticaSistemaEroganteDescr)
	--
	-- Restituisco
	--	
	RETURN 

END