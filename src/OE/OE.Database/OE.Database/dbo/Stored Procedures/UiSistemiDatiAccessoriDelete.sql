


create PROCEDURE [dbo].[UiSistemiDatiAccessoriDelete]

@IDSistema as uniqueidentifier,
@CodiceDatoAccesorio as varchar (64)

AS
BEGIN
SET NOCOUNT ON

delete from [dbo].DatiAccessoriSistemi
    where IDSistema = @IDSistema 
      and CodiceDatoAccessorio = @CodiceDatoAccesorio

SET NOCOUNT OFF
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiSistemiDatiAccessoriDelete] TO [DataAccessUi]
    AS [dbo];

