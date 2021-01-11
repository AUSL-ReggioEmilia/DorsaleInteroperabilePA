

CREATE PROC [organigramma_admin].[PermessiUtentiOttieni]
(
 @Id uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT OFF

  SELECT 
      [Id],
      [Utente],
      [Lettura],
      [Scrittura],
      [Cancellazione],
      [Disattivato]
  FROM  [organigramma].[PermessiUtenti]
  WHERE [Id] = @Id

END

GO


