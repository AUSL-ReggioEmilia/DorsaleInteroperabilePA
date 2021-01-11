

CREATE PROCEDURE [dbo].[PazientiUiSistemiProvenienza] 
	@IdPaziente as uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

select * from (select
	P.Provenienza, 
	P.IdProvenienza, 
	(CASE 
		WHEN P.Disattivato = 0 THEN 'Attivo' 
		WHEN P.Disattivato = 1 THEN 'Cancellato'
		WHEN P.Disattivato = 2 THEN 'Fuso'
	
	END) AS Stato, 
	P.DataModifica
	from Pazienti P
	where P.Id = @IdPaziente
union
	select 
	P.Provenienza, 
	P.IdProvenienza, 
	(CASE 
		WHEN P.Disattivato = 0 THEN 'Attivo' 
		WHEN P.Disattivato = 1 THEN 'Cancellato'
		WHEN P.Disattivato = 2 THEN 'Fuso'
	
	END) AS Stato, 
	P.DataModifica
	from PazientiSinonimi S inner join Pazienti P on P.Provenienza = S.Provenienza AND P.IdProvenienza = S.IdProvenienza 
	where S.IdPaziente = @IdPaziente and S.Abilitato = 1) as asda	
	order by Stato, DataModifica DESC
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiSistemiProvenienza] TO [DataAccessUi]
    AS [dbo];

