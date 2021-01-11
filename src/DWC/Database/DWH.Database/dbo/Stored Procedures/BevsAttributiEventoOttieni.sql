



-- =============================================
-- Author:		Simone Bitti
-- Modify date: 2017-03-09
-- Description:	Ottiene gli attributi di un evento in base all'id dell'evento.
-- =============================================
CREATE PROCEDURE [dbo].[BevsAttributiEventoOttieni]
(
 @IdEvento UNIQUEIDENTIFIER
)
AS
BEGIN
  SET NOCOUNT OFF

  SELECT IdEventiBase,
	Nome,
	Valore,
	DataPartizione
  FROM  [store].[EventiAttributi]
  WHERE [IdEventiBase] = @IdEvento
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsAttributiEventoOttieni] TO [ExecuteFrontEnd]
    AS [dbo];

