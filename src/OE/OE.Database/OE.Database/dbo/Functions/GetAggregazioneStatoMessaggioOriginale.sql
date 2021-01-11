



CREATE FUNCTION [dbo].[GetAggregazioneStatoMessaggioOriginale](
	@messaggio as xml,
    @separator varchar(10)
)
returns varchar(max)
AS
BEGIN

	DECLARE @returnValue VARCHAR(MAX) = '';
	
	DECLARE @tabellaStati as table(statoOrderEntry varchar(max)) 
	
	insert into @tabellaStati 
	select * from dbo.GetStatiDaMessaggioXml(@messaggio)
	
	if ((select count(*) from @tabellaStati) = (select count(*) from @tabellaStati where statoOrderEntry = 'CA')) return 'CA'

	SELECT 	
		@returnValue = @returnValue + Stati.StatoOrderEntry + @separator 
	FROM
		@tabellaStati as Stati where statoOrderEntry <> 'CA'
    
    IF LEN(@returnValue) = 0 RETURN NULL 
    
    RETURN SUBSTRING(@returnValue,1,CASE WHEN LEN(@returnValue) <= LEN(@separator) THEN 0 ELSE LEN(@returnValue)-LEN(@separator) END)
    
END


