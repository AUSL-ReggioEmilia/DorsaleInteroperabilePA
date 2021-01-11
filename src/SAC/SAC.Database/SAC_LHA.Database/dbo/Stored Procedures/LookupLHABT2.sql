

CREATE PROCEDURE [dbo].[LookupLHABT2]
 @Nazionalita VARCHAR(3)= null,
 @RegioneRes VARCHAR(3)= null,
 @RegioneAss VARCHAR(3)= null,
 @ComuneRecapito varchar(6)= null,
 @ASLRes VARCHAR(3)= null,
 @ASLAss VARCHAR(3)= null
AS
BEGIN

DECLARE @TabellaTemporanea AS TABLE(
		IstatRegioneRes VARCHAR(3),
		IstatRegioneAss VARCHAR(3), 
		IstatNazionalita VARCHAR(3), 
		IstatComuneRecapito varchar(6),
		IstatASLRes VARCHAR(3),
		IstatASLAss VARCHAR(3))
		
		
DECLARE  @IstatNazionalita VARCHAR(3)
DECLARE  @IstatRegioneRes VARCHAR(3)
DECLARE  @IstatRegioneAss VARCHAR(3)
DECLARE  @IstatComuneRecapito VARCHAR(6)
DECLARE  @IstatASLRes VARCHAR(3)
DECLARE  @IstatASLAss VARCHAR(3)

--- **********************************************************
--- Fix per nuova versione connettore :
if @Nazionalita = ''
begin
	set @Nazionalita = null
end

if @RegioneRes = ''
begin
	set @RegioneRes = null
end

if @RegioneAss = ''
begin
	set @RegioneAss = null
end

IF @ComuneRecapito = ''
begin
	set @ComuneRecapito = null
end

IF @ASLRes = ''
begin
	set @ASLRes = null
end

IF @ASLAss = ''
begin
	set @ASLAss = null
end

--- **********************************************************

-- Codici AUSL
IF @ASLRes IS NOT NULL
BEGIN
	SET @IstatASLRes = RIGHT('000' + @ASLRes, 3) 
END

IF @ASLAss IS NOT NULL
BEGIN
SET @IstatASLAss = RIGHT('000' + @ASLAss, 3)  
END

-- Regioni
IF @RegioneRes IS NOT NULL
BEGIN
	SET @IstatRegioneRes = RIGHT('000' + @RegioneRes,3)
END

IF @RegioneAss IS NOT NULL
BEGIN
	SET @IstatRegioneAss = RIGHT('000' + @RegioneAss,3)
END


-- ComuneRecapito
SELECT @IstatComuneRecapito = IstatComune 
FROM 
	DizionariLhaComuni
WHERE (CodiceInternoComune = @ComuneRecapito) AND (flagcomunestatoestero = 'C')

IF @IstatComuneRecapito IS NULL
BEGIN
	SET @IstatComuneRecapito = RIGHT('000000' + @ComuneRecapito,6)
END


-- Nazioni
IF NOT @Nazionalita IS NULL
BEGIN
    -- Nel dizionario LHA il valore 100 è mappato con un codice ISTAT non valido
    IF (@Nazionalita = '100')
	BEGIN
        SET @IstatNazionalita = '100'
	END
	ELSE
	BEGIN
	    SELECT @IstatNazionalita = IstatNazione
	    FROM 
			DizionariLhaNazioni
	    WHERE CodiceInternoNazione = @Nazionalita  
	END
END

INSERT INTO @TabellaTemporanea VALUES(
  @IstatRegioneRes,
  @IstatRegioneAss,
  @IstatNazionalita,
  @IstatComuneRecapito,
  @IstatASLRes,
  @IstatASLAss
)
SELECT * FROM @TabellaTemporanea AS ISTAT
END
 



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[LookupLHABT2] TO [Execute Biztalk]
    AS [dbo];

