



-- =============================================
-- Author:		Simone Bitti
-- Modify date: 2017-03-24
-- Description:	Ottiene gli attributi di un referto in base all'id.
-- =============================================
CREATE PROCEDURE [dbo].[BevsAttributiRefertoOttieni]
(
 @IdReferto UNIQUEIDENTIFIER
)
AS
BEGIN
  SET NOCOUNT OFF

  SELECT IdRefertiBase,
	Nome,
	Valore,
	DataPartizione
  FROM  [store].[RefertiAttributi]
  WHERE [IdRefertiBase] = @IdReferto
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsAttributiRefertoOttieni] TO [ExecuteFrontEnd]
    AS [dbo];

