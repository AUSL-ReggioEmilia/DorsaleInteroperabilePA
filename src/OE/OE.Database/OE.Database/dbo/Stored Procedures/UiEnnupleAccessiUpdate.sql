

-- =============================================
-- Author:		
-- Create date: 
-- Description:	Esegue l'update di un'ennupla relativa ad un accesso
-- ModifyDate: 26/03/2019
-- By: LucaB.
-- =============================================

CREATE PROCEDURE [dbo].[UiEnnupleAccessiUpdate]

 @ID as uniqueidentifier
,@UtenteModifica as varchar(64)
,@IDGruppoUtenti as uniqueidentifier = NULL
,@Descrizione as varchar(256)
,@IDSistemaErogante as uniqueidentifier = NULL
,@Lettura as bit
,@Inoltro as bit
,@Scrittura as bit
,@Inverso as bit = 0
,@IDStato as tinyint
,@Note as varchar(1024)
AS
BEGIN
SET NOCOUNT ON

UPDATE [dbo].[EnnupleAccessi]
   SET [DataModifica] = GETDATE()
      ,[UtenteModifica] = @UtenteModifica
      ,[IDGruppoUtenti] = @IDGruppoUtenti  
      ,Descrizione = @Descrizione
      ,IDSistemaErogante = @IDSistemaErogante
      ,R = @Lettura
      ,I = @Scrittura
      ,S = @Inoltro
      ,[Not] = @Inverso
      ,[IDStato] = @IDStato
	  ,[Note] = @Note
      
 WHERE ID = @ID

select * from [dbo].[EnnupleAccessi]  WHERE ID = @ID

SET NOCOUNT OFF
END






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiEnnupleAccessiUpdate] TO [DataAccessUi]
    AS [dbo];

