
CREATE  PROCEDURE [dbo].[LookupLHABTGet]
	@ComuneNas varchar(6) = null,
	@ComuneRes varchar(6)= null,
	@ComuneDom varchar(6)= null,
	@ComuneRecapito varchar(6)= null,
	@Nazionalita varchar(3)= null,
	@RegioneRes varchar(3)= null,
	@RegioneAss varchar(3)= null,
	@ASLRes varchar(3)= null,
	@ASLAss varchar(3)= null
AS
BEGIN

declare @TabellaTemporanea as table(
IstatComuneNas varchar(6), IstatComuneRes varchar(6), IstatComuneDom varchar(6), IstatComuneRecapito varchar(6),
IstatRegioneRes varchar(3),IstatRegioneAss varchar(3), IstatNazionalita varchar(3), IstatASLRes varchar(3),
IstatASLAss varchar(3))

if not(@ComuneNas is null)  
begin 

declare  @IstatComuneNas varchar(6) 
declare  @IstatComuneRes varchar(6)
declare  @IstatComuneDom varchar(6)
declare  @IstatComuneRecapito varchar(6)
declare  @IstatNazionalita varchar(3)
declare  @IstatRegioneRes varchar(3)
declare  @IstatRegioneAss varchar(3)
declare  @IstatASLRes varchar(3)
declare  @IstatASLAss varchar(3)
declare  @StatoEstero varchar(1)

set @IstatASLRes = @ASLRes
set @IstatASLAss = @ASLAss

-- Reupero il codice Istat del comune di nascita
--AND (flagstatoestero = 'C')
select @IstatComuneNas = CodIstatComune, @StatoEstero = flagstatoestero  from comuni where (CodAziendaleComune = @ComuneNas) 
IF NOT @IstatComuneNas IS NULL
BEGIN
	-- Riempio di 0 il valore del comune per avere un mapping con i codici istat del sac
	SET @IstatComuneNas = RIGHT('000000' + @IstatComuneNas,6)
END

-- Reupero il codice Istat del comune di residenza
select @IstatComuneRes = CodIstatComune from comuni where (CodAziendaleComune = @ComuneRes) AND (flagstatoestero = 'C')
IF NOT @IstatComuneRes IS NULL
BEGIN
	-- Riempio di 0 il valore del comune per avere un mapping con i codici istat del sac
	SET @IstatComuneRes = RIGHT('000000' + @IstatComuneRes,6)
END

-- Reupero il codice Istat del comune di domicilio
select @IstatComuneDom = CodIstatComune from comuni where (CodAziendaleComune = @ComuneDom) AND (flagstatoestero = 'C')
IF NOT @IstatComuneDom IS NULL
BEGIN
	-- Riempio di 0 il valore del comune per avere un mapping con i codici istat del sac
	SET @IstatComuneDom = RIGHT('000000' + @IstatComuneDom,6)
END

-- Reupero il codice Istat del comune di recapito
select @IstatComuneRecapito = CodIstatComune from comuni where (CodAziendaleComune = @ComuneRecapito) AND (flagstatoestero = 'C')
IF NOT @IstatComuneRecapito IS NULL
BEGIN
	-- Riempio di 0 il valore del comune per avere un mapping con i codici istat del sac
	SET @IstatComuneRecapito = RIGHT('000000' + @IstatComuneRecapito,6)
END

-- recupero i codici istat delle regioni
select @IstatRegioneRes = CodiceIstatRegione from RegioniAslIstat where (CodiceAslRegione = @RegioneRes)
select @IstatRegioneAss = CodiceIstatRegione from RegioniAslIstat where (CodiceAslRegione = @RegioneAss)

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
						Set @IstatNazionalita = Right('000' + @IstatComuneNas,3)
					END
				END
			END
            ELSE
			BEGIN
				set @IstatNazionalita = @Nazionalita
			END
	 END
END
ELSE
BEGIN
    IF NOT @StatoEstero iS NULL
    BEGIN    
       IF @StatoEstero = 'E'
       BEGIN     
          Set @IstatNazionalita = Right('000' + @IstatComuneNas,3)
       END
    END
END

--print @IstatNazionalita
--print len(@IstatNazionalita)

insert into @TabellaTemporanea values(
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

select 
isnull(IstatComuneNas, '') as IstatComuneNas,
isnull(IstatComuneRes, '') as IstatComuneRes,
isnull(IstatComuneDom, '') as IstatComuneDom,
isnull(IstatComuneRecapito, '') as IstatComuneRecapito,
isnull(IstatRegioneRes, '') as IstatRegioneRes,
isnull(IstatRegioneAss, '') as IstatRegioneAss,
isnull(IstatNazionalita, '') as IstatNazionalita,
isnull(IstatASLRes, '') as IstatASLRes,
isnull(IstatASLAss, '') as IstatASLAss
from @TabellaTemporanea as ISTAT for XML AUTO, ELEMENTS

-- Con questa sotto non funziona!!
--select * from @TabellaTemporanea as ISTAT for XML AUTO, ELEMENTS
end
else
BEGIN
select * from @TabellaTemporanea as ISTAT where 1 = 2 FOR XML AUTO, ELEMENTS, XMLDATA
END

END








GO
GRANT EXECUTE
    ON OBJECT::[dbo].[LookupLHABTGet] TO [Execute Biztalk]
    AS [dbo];

