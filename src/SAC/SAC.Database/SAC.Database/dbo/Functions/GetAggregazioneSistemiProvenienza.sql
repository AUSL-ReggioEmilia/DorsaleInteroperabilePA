
CREATE FUNCTION [dbo].[GetAggregazioneSistemiProvenienza]
(
@idPaziente as uniqueidentifier,
@separator as varchar(10)
)
returns varchar(max)
AS
BEGIN

DECLARE @returnValue VARCHAR(MAX);

SET @returnValue = '';

SELECT 	@returnValue = @returnValue + SistemiDescrizioni.Provenienza + @separator 
FROM (select (P.Provenienza + ' (' + P.IdProvenienza + ')') as Provenienza

	from PazientiSinonimi S inner join Pazienti P on P.Provenienza = S.Provenienza AND P.IdProvenienza = S.IdProvenienza 
	where S.IdPaziente = @IdPaziente and S.Abilitato = 1) as SistemiDescrizioni
    
    IF LEN(@returnValue) = 0 RETURN NULL 
    
    RETURN SUBSTRING(@returnValue,1,CASE WHEN LEN(@returnValue) <= LEN(@separator) THEN 0 ELSE LEN(@returnValue)-LEN(@separator) END)

END






