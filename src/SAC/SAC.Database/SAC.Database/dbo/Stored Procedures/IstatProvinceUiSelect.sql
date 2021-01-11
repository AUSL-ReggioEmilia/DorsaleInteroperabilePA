

CREATE PROCEDURE [dbo].[IstatProvinceUiSelect]
(
	@Codice varchar(3)
)
AS

BEGIN
  SET NOCOUNT OFF

  SELECT 
      [Codice],
      [Nome],
      [Sigla],
      [CodiceRegione]
  FROM  [IstatProvince]
  WHERE [Codice] = @Codice

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IstatProvinceUiSelect] TO [DataAccessUi]
    AS [dbo];

