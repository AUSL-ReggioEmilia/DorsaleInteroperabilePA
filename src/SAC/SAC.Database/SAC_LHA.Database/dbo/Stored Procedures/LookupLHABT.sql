
CREATE  PROCEDURE [dbo].[LookupLHABT]
 @ComuneNas VARCHAR(6) = null,
 @ComuneRes VARCHAR(6)= null,
 @ComuneDom VARCHAR(6)= null,
 @ComuneRecapito VARCHAR(6)= null,
 @Nazionalita VARCHAR(3)= null,
 @RegioneRes VARCHAR(3)= null,
 @RegioneAss VARCHAR(3)= null,
 @ASLRes VARCHAR(3)= null,
 @ASLAss VARCHAR(3)= null
AS
BEGIN
	DECLARE @TabellaTemporanea AS TABLE(
		IstatComuneNas VARCHAR(6), IstatComuneRes VARCHAR(6), IstatComuneDom VARCHAR(6), IstatComuneRecapito VARCHAR(6),
		IstatRegioneRes VARCHAR(3),IstatRegioneAss VARCHAR(3), IstatNazionalita VARCHAR(3), IstatASLRes VARCHAR(3),
		IstatASLAss VARCHAR(3))
	
	DECLARE  @IstatComuneNas VARCHAR(6) 
	DECLARE  @IstatComuneRes VARCHAR(6)
	DECLARE  @IstatComuneDom VARCHAR(6)
	DECLARE  @IstatComuneRecapito VARCHAR(6)
	DECLARE  @IstatNazionalita VARCHAR(3)
	DECLARE  @IstatRegioneRes VARCHAR(3)
	DECLARE  @IstatRegioneAss VARCHAR(3)
	DECLARE  @IstatASLRes VARCHAR(3)
	DECLARE  @IstatASLAss VARCHAR(3)
	DECLARE  @StatoEstero VARCHAR(1)
	
	-- Codici AUSL
	SET @IstatASLRes = @ASLRes
	SET @IstatASLAss = @ASLAss
	
	-- Reupero il codice Istat del comune di nascita
	SELECT @IstatComuneNas = CodIstatComune, @StatoEstero = flagstatoestero  
	FROM comuni 
	WHERE (CodAziendaleComune = @ComuneNas) 
	IF NOT @IstatComuneNas IS NULL
	BEGIN
	 -- Riempio di 0 il valore del comune per avere un mapping con i codici istat del sac
	 SET @IstatComuneNas = RIGHT('000000' + @IstatComuneNas,6)
	END
	ELSE
	BEGIN
	 SET @IstatComuneNas = RIGHT('000000' + @ComuneNas,6)
	END
	-- Reupero il codice Istat del comune di residenza
	SELECT @IstatComuneRes = CodIstatComune 
	FROM comuni 
	WHERE (CodAziendaleComune = @ComuneRes) AND (flagstatoestero = 'C')
	IF NOT @IstatComuneRes IS NULL
	BEGIN
	 -- Riempio di 0 il valore del comune per avere un mapping con i codici istat del sac
	 SET @IstatComuneRes = RIGHT('000000' + @IstatComuneRes,6)
	END
	ELSE
	BEGIN
	 SET @IstatComuneRes = RIGHT('000000' + @ComuneRes,6)
	END
	-- Reupero il codice Istat del comune di domicilio
	SELECT @IstatComuneDom = CodIstatComune 
	FROM comuni 
	WHERE (CodAziendaleComune = @ComuneDom) AND (flagstatoestero = 'C')
	IF NOT @IstatComuneDom IS NULL
	BEGIN
	 -- Riempio di 0 il valore del comune per avere un mapping con i codici istat del sac
	 SET @IstatComuneDom = RIGHT('000000' + @IstatComuneDom,6)
	END
	ELSE
	BEGIN
	 SET @IstatComuneDom = RIGHT('000000' + @ComuneDom,6)
	END
	-- Reupero il codice Istat del comune di recapito
	SELECT @IstatComuneRecapito = CodIstatComune 
	FROM comuni 
	WHERE (CodAziendaleComune = @ComuneRecapito) AND (flagstatoestero = 'C')
	IF NOT @IstatComuneRecapito IS NULL
	BEGIN
	 -- Riempio di 0 il valore del comune per avere un mapping con i codici istat del sac
	 SET @IstatComuneRecapito = RIGHT('000000' + @IstatComuneRecapito,6)
	END
	ELSE
	BEGIN
	 SET @IstatComuneRecapito = RIGHT('000000' + @ComuneRecapito,6)
	END
	-- recupero i codici istat delle regioni
	SELECT @IstatRegioneRes = CodiceIstatRegione 
	FROM RegioniAslIstat 
	WHERE (CodiceAslRegione = @RegioneRes)
	IF @IstatRegioneRes IS NULL
	BEGIN
	 SET @IstatRegioneRes = RIGHT('000' + @RegioneRes,3)
	END
	SELECT @IstatRegioneAss = CodiceIstatRegione 
	FROM RegioniAslIstat 
	WHERE (CodiceAslRegione = @RegioneAss)
	IF @IstatRegioneAss IS NULL
	BEGIN
	 SET @IstatRegioneAss = RIGHT('000' + @RegioneAss,3)
	END

	IF NOT @Nazionalita IS NULL
	BEGIN
		-- in LHA la nazionalità italiana è mappata anche con la lettera I; nel caso setto il codice istat a 100(Italia) 
		IF @Nazionalita like '%I%'
	 BEGIN
			SET @IstatNazionalita = '100'
	 END
	 ELSE
	 BEGIN
	   IF (@Nazionalita = '000') OR (@Nazionalita = '0')
	   BEGIN
		IF NOT @StatoEstero iS NULL
		BEGIN    
		 IF @StatoEstero = 'E'
		 BEGIN     
		  SET @IstatNazionalita = Right('000' + @IstatComuneNas,3)
		 END
		END
	   END
				ELSE
	   BEGIN
		SET @IstatNazionalita = @Nazionalita
	   END
	  END
	END
	ELSE
	BEGIN
		IF NOT @StatoEstero IS NULL
		BEGIN    
		   IF @StatoEstero = 'E'
		   BEGIN     
			  Set @IstatNazionalita = Right('000' + @IstatComuneNas,3)
		   END
		END
	END

	INSERT INTO @TabellaTemporanea VALUES(
	  @IstatComuneNas, 
	  @IstatComuneRes,
	  @IstatComuneDom,
	  @IstatComuneRecapito,
	  @IstatRegioneRes,
	  @IstatRegioneAss,
	  @IstatNazionalita,
	  @IstatASLRes,
	  @IstatASLAss
	)
	SELECT * FROM @TabellaTemporanea AS ISTAT
END

 
--DELETE 
--FROM RegioniAslIstat
--WHERE CodiceASLRegione <> '41' AND CodiceASLRegione <> '42'

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[LookupLHABT] TO [Execute Biztalk]
    AS [dbo];

