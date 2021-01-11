


-- =============================================
-- Author:		???
-- Create date: ???
-- Description:	Funzione che ritorna l'Id del paziente di una specifica anagrafica
-- Modify date: 2015-07-16 - ETTORE: Nel caso il parametro @Anagrafica sia uguale a 'SAC' la versione precedente cercava
--									 nella vista PazientiBase che restituisce solo gli attivi.
--									 Poichè la vista PazientiRiferimenti restituisce tutti i sinonimi del tipo SAC_<guidattivo>, <SAC_guidfuso> e <XXX_YYY>
--									 ora per quasiasi valore di @Anagrafica <> '' e @IdAnagrafica <> '' posso cercare nella vista PazientiRiferimenti.
-- Modify date: 2016-05-12 - SANDRO: Usa nuova vista [sac].[PazientiRiferimenti]
-- Modify date: 2019-02-12 - ETTORE: Miglioramento prestazioni; non uso la vista [sac].[PazientiRiferimenti] ma la [sac].Pazienti 
--									 cercando in modo differente in base al parametro @Anagrafica 
-- =============================================
CREATE FUNCTION dbo.GetPazientiIdByRiferimento (@Anagrafica varchar(16),  @IdAnagrafica varchar(64))
RETURNS  uniqueidentifier AS  
BEGIN 
	DECLARE @Ret uniqueidentifier = NULL

	IF @Anagrafica <> '' AND @IdAnagrafica <> ''
	BEGIN
             IF @Anagrafica = 'SAC'
             BEGIN 
                    --Controllo che @IdAnagrafica sia un GUID
					IF dbo.IsGUID(@IdAnagrafica) = 1
					BEGIN 
						SELECT @Ret = IsNUll(FusioneId, Id) --Restituisco l’attivo altrimenti l'Id stesso
						FROM [sac].[Pazienti] WITH(NOLOCK) 
						WHERE Id = @IdAnagrafica
					END
             END
             ELSE
             BEGIN 
                    SELECT @Ret = IsNUll(FusioneId, Id) 
                    FROM [sac].[Pazienti] WITH(NOLOCK) --Restituisco l’attivo altrimenti l'Id stesso
                    WHERE  NomeAnagraficaErogante = @Anagrafica
                           AND CodiceAnagraficaErogante = @IdAnagrafica
             END 
	END
	--
	--
	--		
	RETURN @Ret
END

