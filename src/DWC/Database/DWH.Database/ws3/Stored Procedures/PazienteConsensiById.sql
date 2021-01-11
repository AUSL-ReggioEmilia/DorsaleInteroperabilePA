
-- =============================================
-- Author:		Ettore Garulli
-- Create date: 2016-05-20
-- Description:	Restituisce i consensi del paziente
-- =============================================
CREATE PROCEDURE [ws3].[PazienteConsensiById]
(
	@IdPaziente UNIQUEIDENTIFIER
)
AS
BEGIN
/*
	Ricava i consensi di un paziente per il dettaglio paziente.
	Al momento sac.OttieneConsensiPerIdSac() utilizza la vista del SAC ConsensiOutput.
	Sarebbe meglio che il SAC esponesse una vista di output uguale alla ConsensiPazienteAggregati
	così non sarebbe necessario rifare all'interno della SP l'aggregazione
	(inoltre l'aggregazione la posso fare solo su Descrizione e DataStato in quanto la vista ConsensiOutput del SAC
	non espone la data di inserimento)
*/
	SET NOCOUNT ON;
	--
	-- Tabella temporanea per contenere tutti i consensi
	--
	DECLARE @ConsensiTutti TABLE(
		Id uniqueidentifier, IdPaziente uniqueidentifier, Descrizione varchar(64), DataStato datetime, Stato bit
		, OperatoreId varchar(64), OperatoreCognome varchar(64), OperatoreNome varchar(64), OperatoreComputer varchar(64)
		)
	--			
	-- Traslo l'idpaziente nell'idpaziente attivo			
	--
	SELECT @IdPaziente = dbo.GetPazienteAttivoByIdSac(@IdPaziente)
	--
	-- Lista dei fusi + l'attivo
	--
	DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
	INSERT INTO @TablePazienti(Id)
		SELECT Id
		FROM dbo.GetPazientiDaCercareByIdSac(@IdPaziente)
	--
	-- Leggo tutti i consensi
	--
	INSERT INTO @ConsensiTutti (Id , IdPaziente , Descrizione, DataStato, Stato
		, OperatoreId, OperatoreCognome, OperatoreNome, OperatoreComputer)
	SELECT 
		C.Id
		, @IdPaziente AS IdPaziente
		--Questa è la descrizione del consenso
		, Descrizione
		, C.DataStato
		, C.Stato
		, C.OperatoreId
		, C.OperatoreCognome
		, C.OperatoreNome
		, C.OperatoreComputer
	FROM 
		@TablePazienti P
		CROSS APPLY sac.OttieneConsensiPerIdSac(P.Id) AS C

	--
	-- Eseguo aggregazione e restituisco
	-- Non avendo l'IdTipo del consenso aggrego sulla descrizione
	-- Poi ordino per DataStato e Descrizione del consenso
	--
	SELECT 
			Id
			, IdPaziente --IdPaziente è lo stesso per tutti i consensi
			, Descrizione
			, DataStato
			, Stato
			, OperatoreId
			, OperatoreCognome
			, OperatoreNome
			, OperatoreComputer
	FROM ( 
		SELECT DISTINCT
			C.Id
			, C.IdPaziente --IdPaziente è lo stesso per tutti i consensi
			, C.Descrizione
			, C.DataStato
			, C.Stato
			, C.OperatoreId
			, C.OperatoreCognome
			, C.OperatoreNome
			, C.OperatoreComputer
		FROM 
			@ConsensiTutti AS C
			INNER JOIN 
				( 
					-- Ricavo: C.IdPaziente, C.Descrizione con DataStatoMax
					SELECT 
						C.Descrizione, MAX(C.DataStato) AS DataStatoMax
					FROM 
						@ConsensiTutti C 
					GROUP BY 
						--Non raggruppo per C.IdPaziente poichè è lo stesso per tutii i record
						C.Descrizione
				) AS TAB1
			ON 
				C.DataStato = TAB1.DataStatoMax
				AND C.Descrizione= TAB1.Descrizione
		) AS TAB
	ORDER BY 
		DataStato 
		--A parità di DataStato prima il "Generico" poi il "Dossier" e poi il "DossierStorico"
		, CASE WHEN Descrizione = 'Generico' THEN 1
				WHEN Descrizione = 'Dossier' THEN 2
				WHEN Descrizione = 'DossierStorico' THEN 3
				ELSE 0 END

		
END